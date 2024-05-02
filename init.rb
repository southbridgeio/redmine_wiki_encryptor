Redmine::Plugin.register :redmine_wiki_encryptor do
  name 'Redmine Wiki Encryptor plugin'
  author 'Pavel Nemkin'
  description 'Plugin encrypts wiki content in database'
  version '0.0.5'
  url 'https://github.com/southbridgeio/redmine_wiki_encryptor'
  author_url 'https://southbridge.io'

  Redmine::AccessControl.map do |map|
    map.project_module :wiki do |map|
      map.permission :edit_indexable, { :redmine_wiki_encryptor => [:change_not_index] }
    end
  end
end

register_after_redmine_initialize_proc =
  if Redmine::VERSION::MAJOR >= 5
    Rails.application.config.public_method(:after_initialize)
  else
    reloader = defined?(ActiveSupport::Reloader) ? ActiveSupport::Reloader : ActionDispatch::Reloader
    reloader.public_method(:to_prepare)
  end
register_after_redmine_initialize_proc.call do
  require File.dirname(__FILE__) + '/lib/wiki_encryptor'
  require File.dirname(__FILE__) + '/lib/redmine_wiki_encryptor/hooks.rb'
  require_dependency File.dirname(__FILE__) + '/lib/wiki_content_patch'
  require_dependency File.dirname(__FILE__) + '/lib/wiki_content_version_patch'
  require_dependency File.dirname(__FILE__) + '/lib/wiki_page_patch'
end
