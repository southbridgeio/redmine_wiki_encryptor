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
            content.text = content['text']
            content.update_columns(text: '',
                                   encrypted_text: content.encrypted_text,
                                   encrypted_text_iv: content.encrypted_text_iv)
            content.versions.each do |content_version|
              content_version.text = content_version.text_without_encryption
              content_version.update_column(:data, content_version.data)
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
            content.update_columns(text: content.text, encrypted_text: nil, encrypted_text_iv: nil)
            content.versions.each do |content_version|
              content_version.text_without_encryption = content_version.text
              content_version.update_column(:data, content_version.data)
            end
          end
          content_count += 1
        end
      end
      puts "#{content_count} pages decrypted"
    end
  end

end
