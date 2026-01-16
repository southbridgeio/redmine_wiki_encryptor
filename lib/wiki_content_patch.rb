require_dependency "wiki_content"
require_dependency "setting"

module WikiContentPatch

  def self.included(base)
    unless WikiEncryptor::Configuration.key.nil?
      base.send(:attr_encrypted, :text,
                key: WikiEncryptor::Configuration.key,
                algorithm: WikiEncryptor::Configuration.algorithm)
      base.send(:prepend, InstanceMethods)
      base.send(:after_initialize, :disable_cache_formatted_text)
      base.send(:before_save, :clear_text_field)
    end
  end

  module InstanceMethods
    def text_changed?
      encrypted_text_changed?
    end

    private

    def clear_text_field
      # Rails 7.2+ with attr_encrypted writes decrypted value to @attributes
      # which gets saved to DB. We need to clear it to keep only encrypted data.
      write_attribute(:text, '') if encrypted_text.present?
    end

    def disable_cache_formatted_text
      Setting['cache_formatted_text'] = 0
    end

    def create_version
      version = WikiContentVersion.new(attributes.slice(*WikiContentVersion.attribute_names).except('id'))
      version.wiki_content_id = id
      version.text = text
      version.save!
    end
  end
end

WikiContent.send(:include, WikiContentPatch)
