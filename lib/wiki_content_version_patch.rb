require_dependency "wiki_content"

module WikiContentVersionPatch

  def self.included(base)
    base.send(:include, InstanceMethods)
    unless WikiEncryptor::Configuration.key.nil?
      base.class_eval do
        alias_method :text_without_encryption, :text
        alias_method :text, :text_with_encryption

        alias_method :text_without_encryption=, :text=
        alias_method :text=, :text_with_encryption=
      end
    end
  end

  module InstanceMethods

    def encrypted_text=(value)
      # stub for act_as_versioned
    end

    def text_with_encryption=(value)
      encrypted = WikiContent.encrypt_text(value, iv: iv)
      self.text_without_encryption = "#{encrypted}:#{[iv].pack('m')}"
    end

    def text_with_encryption
      encrypted, iv = self.text_without_encryption.split(':')
      WikiContent.decrypt_text(encrypted, iv: iv.unpack('m').first)
    end

    private

    def iv
      page.content.encrypted_text_iv.unpack('m').first
    end
  end

end

WikiContent::Version.send(:include, WikiContentVersionPatch)