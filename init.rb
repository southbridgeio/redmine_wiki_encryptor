Redmine::Plugin.register :redmine_wiki_encryptor do
  name 'Redmine Wiki Encryptor plugin'
  author 'Pavel Nemkin'
  description 'Plugin encrypts wiki content in database'
  version '0.1.0'
  url 'https://github.com/southbridgeio/redmine_wiki_encryptor'
  author_url 'https://southbridge.io'

  requires_redmine version_or_higher: '5.1'

  Redmine::AccessControl.map do |map|
    map.project_module :wiki do |map|
      map.permission :edit_indexable, { :redmine_wiki_encryptor => [:change_not_index] }
    end
  end
end

Rails.application.config.after_initialize do
  require File.dirname(__FILE__) + '/lib/wiki_encryptor'
  require File.dirname(__FILE__) + '/lib/redmine_wiki_encryptor/hooks.rb'
  require_dependency File.dirname(__FILE__) + '/lib/wiki_content_patch'
  require_dependency File.dirname(__FILE__) + '/lib/wiki_content_version_patch'
  require_dependency File.dirname(__FILE__) + '/lib/wiki_page_patch'
end
