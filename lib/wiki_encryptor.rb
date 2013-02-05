module WikiEncryptor

  module Configuration

    def self.key
      configuration = Redmine::Configuration['wiki_encryptor']
      configuration && configuration['key'] ? configuration['key'] : nil
    end

    def self.algorithm
      configuration = Redmine::Configuration['wiki_encryptor']
      configuration && configuration['algorithm'] ? configuration['algorithm'] : 'aes-256-cbc'
    end

  end

  def self.encrypt
    if WikiEncryptor::Configuration.key.nil?
      puts "Specify wiki encryptor key"
    else
      content_count = 0
      WikiContent.find_each do |content|
        ActiveRecord::Base.transaction do
          unless content.attributes['text'].blank?
            content.update_column(:encrypted_text, WikiContent.encrypt_text(content.attributes['text']))
            content.update_column(:text, "")
            content.versions.each do |content_version|
              content_version.text = content_version.text_without_encryption
              content_version.save
            end
          end
          content_count += 1
        end
      end
      puts "#{content_count} pages encrypted"
    end
  end

  def self.decrypt
    if WikiEncryptor::Configuration.key.nil?
      puts "Specify wiki encryptor key"
    else
      content_count = 0
      WikiContent.find_each do |content|
        ActiveRecord::Base.transaction do
          unless content.attributes['encrypted_text'].blank?
            content.update_column(:text, WikiContent.decrypt_text(content.attributes['encrypted_text']))
            content.update_column(:encrypted_text, "")
            content.versions.each do |content_version|
              content_version.text_without_encryption = content_version.text
              content_version.save
            end
          end
          content_count += 1
        end
      end
      puts "#{content_count} pages decrypted"
    end
  end

end