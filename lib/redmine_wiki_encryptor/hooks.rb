class RedmineWikiEnctyptorHooks < Redmine::Hook::ViewListener
  render_on :view_layouts_base_html_head, :partial => 'redmine_wiki_encryptor/not_index_wiki_page', :layout => false
end
