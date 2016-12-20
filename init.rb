Redmine::Plugin.register :redmine_wiki_encryptor do
  name 'Redmine Wiki Encryptor plugin'
  author 'Pavel Nemkin'
  description 'Plugin encrypts wiki content in database'
  version '0.0.5'
  url 'https://github.com/centosadmin/redmine_wiki_encryptor'
  author_url 'https://centos-admin.ru'

  Redmine::AccessControl.map do |map|
    map.project_module :wiki do |map|
      map.permission :edit_indexable, {:redmine_wiki_encryptor => [:change_not_index]}
    end
  end
end

ActionDispatch::Callbacks.to_prepare do
  require "wiki_encryptor"
  require "redmine_wiki_encryptor/hooks.rb"
  require_dependency 'wiki_content_patch'
  require_dependency 'wiki_content_version_patch'
  require_dependency 'wiki_page_patch'
end
