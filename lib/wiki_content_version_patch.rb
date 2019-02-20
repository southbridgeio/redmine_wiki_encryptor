require_dependency "wiki_content"

module WikiContentVersionPatch

  def self.included(base)
    unless WikiEncryptor::Configuration.key.nil?
      base.class_eval do
        base.send(:attr_encrypted, :text,
                  key: WikiEncryptor::Configuration.key,
                  algorithm: WikiEncryptor::Configuration.algorithm)
      end
    end
  end
end

WikiContent::Version.send(:include, WikiContentVersionPatch)