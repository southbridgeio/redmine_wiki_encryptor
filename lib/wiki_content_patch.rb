require_dependency "wiki_content"
require_dependency "setting"

module WikiContentPatch

  def self.included(base)
    unless WikiEncryptor::Configuration.key.nil?
      base.send(:attr_encrypted, :text,
                key: WikiEncryptor::Configuration.key,
                algorithm: WikiEncryptor::Configuration.algorithm,
                mode: :single_iv_and_salt,
                insecure_mode: true)
      base.send(:prepend, InstanceMethods)
      base.send(:after_initialize, :disable_cache_formatted_text)
    end
  end

  module InstanceMethods
    def text_changed?
      encrypted_text_changed?
    end

    private

    def disable_cache_formatted_text
      Setting['cache_formatted_text'] = 0
    end

    def create_version
      version =  WikiContentVersion.new(attributes.except("id"))
      version.text = text
      versions << version
    end
  end
end

WikiContent.send(:include, WikiContentPatch)
