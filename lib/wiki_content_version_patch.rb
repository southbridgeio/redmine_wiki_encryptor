require_dependency "wiki_content"

module WikiContentVersionPatch

  def self.included(base)
    base.send(:include, InstanceMethods)
  end

  module InstanceMethods

    def encrypted_text=(value)
      # stub for act_as_versioned
    end

  end

end

WikiContent::Version.send(:include, WikiContentVersionPatch)