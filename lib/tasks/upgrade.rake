namespace :wiki_encryptor do
  task upgrade: :environment do
    class LegacyWikiContent < ActiveRecord::Base
      self.table_name = WikiContent.table_name

      def self.key
        configuration = Redmine::Configuration['wiki_encryptor']
        configuration && configuration['legacy_key'] ? configuration['legacy_key'] : nil
      end

      def self.algorithm
        configuration = Redmine::Configuration['wiki_encryptor']
        configuration && configuration['legacy_algorithm'] ? configuration['legacy_algorithm'] : 'aes-256-cbc'
      end

      attr_encrypted :text,
                     key: key,
                     algorithm: algorithm,
                     mode: :single_iv_and_salt,
                     insecure_mode: true

      has_many :versions, class_name: 'LegacyWikiContentVersion', foreign_key: :wiki_content_id
    end

    class LegacyWikiContentVersion < ActiveRecord::Base
      self.table_name = WikiContent::Version.table_name

      def text
        @text ||= begin
          str = case compression
                when 'gzip'
                  Zlib::Inflate.inflate(data)
                else
                  # uncompressed data
                  data
                end
          str.force_encoding("UTF-8")
          str
        end
      end

      def encrypted_text=(value)
        # stub for act_as_versioned
      end

      def text_with_encryption
        encrypted = self.text_without_encryption
        LegacyWikiContent.decrypt_text(encrypted)
      end

      alias_method :text_without_encryption, :text
      alias_method :text, :text_with_encryption
    end

    ActiveRecord::Base.record_timestamps = false

    LegacyWikiContent.find_each do |legacy_content|
      next if legacy_content.encrypted_text_iv.present?

      ActiveRecord::Base.transaction do
        puts "Reencrypting wiki content ##{legacy_content.id}..."
        content = WikiContent.find(legacy_content.id)
        content.encrypted_text = nil
        content.text = legacy_content.text
        content.update_columns(encrypted_text: content.encrypted_text, encrypted_text_iv: content.encrypted_text_iv)

        legacy_content.versions.each do |legacy_version|
          version = WikiContent::Version.find(legacy_version.id)
          version.text = legacy_version.text
          version.save!
        end
      end
    end
  end
end
