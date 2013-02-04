require_dependency "wiki_content"

module WikiContentPatch

  def self.included(base)
    unless WikiEncryptor::Configuration.key.nil?
      base.send(:attr_encrypted, :text, key: WikiEncryptor::Configuration.key, algorithm: WikiEncryptor::Configuration.algorithm)
      base.send(:include, InstanceMethods)
    end
  end

  module InstanceMethods

    def text_changed?
      encrypted_text_changed?
    end

  end

end

WikiContent.send(:include, WikiContentPatch)