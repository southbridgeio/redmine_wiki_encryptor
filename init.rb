Redmine::Plugin.register :redmine_wiki_encryptor do
  name 'Redmine Wiki Encryptor plugin'
  author 'Pavel Nemkin'
  description 'Plugin encrypts wiki content in database'
  version '0.0.2'
  url 'https://github.com/olemskoi/redmine_wiki_encryptor'
  author_url 'https://github.com/kanfet'
end

ActionDispatch::Callbacks.to_prepare do
  require "wiki_encryptor"
  require_dependency 'wiki_content_patch'
  require_dependency 'wiki_content_version_patch'
  require_dependency 'wiki_page_patch'
end