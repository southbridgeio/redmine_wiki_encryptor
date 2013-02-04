require_dependency "wiki_content"

module WikiContentPatch

  def self.included(base)
    base.send(:attr_encrypted, :text, key: "123")
    base.send(:include, InstanceMethods)
  end

  module InstanceMethods

    def text_changed?
      encrypted_text_changed?
    end

  end

end

WikiContent.send(:include, WikiContentPatch)