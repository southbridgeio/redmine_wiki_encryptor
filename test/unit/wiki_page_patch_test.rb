require File.expand_path('../../test_helper', __FILE__)

class WikiPagePatchTest < ActiveSupport::TestCase
  fixtures :users,
           :members,
           :member_roles,
           :projects,
           :enabled_modules,
           :roles,
           :wikis

  def setup
    @project = Project.find(1)
    @tokens = %w(hello world)

    @page_with_matching_title = WikiPage.create(title: "hello", wiki: @project.wiki)
    WikiContent.create(page: @page_with_matching_title, text: "Some text")

    @page_with_matching_text = WikiPage.create(title: "matched text", wiki: @project.wiki)
    WikiContent.create(page: @page_with_matching_text, text: "world")

    @page_with_matching_title_all_words = WikiPage.create(title: "hello this wonderful WORLD", wiki: @project.wiki)
    WikiContent.create(page: @page_with_matching_title_all_words, text: "Some text")

    @page_with_matching_text_all_words = WikiPage.create(title: "matched text all words", wiki: @project.wiki)
    WikiContent.create(page: @page_with_matching_text_all_words, text: "World! I said HELLO, world!")
  end

  def test_search_by_anonymous
    User.current = nil
    result = WikiPage.search_result_ranks_and_ids(@tokens)
    assert_includes result, wiki_rand_and_id(@page_with_matching_title)
    assert_includes result, wiki_rand_and_id(@page_with_matching_text)
  end

  def test_search_by_anonymous_without_permission
    User.current = nil
    remove_permission Role.anonymous, :view_wiki_pages
    result = WikiPage.search_result_ranks_and_ids(@tokens)
    assert !result.include?(wiki_rand_and_id(@page_with_matching_title))
    assert !result.include?(wiki_rand_and_id(@page_with_matching_text))
  end

  def test_search_by_anonymous_in_private_project
    User.current = nil
    @project.update_attribute :is_public, false
    result = WikiPage.search_result_ranks_and_ids(@tokens)
    assert !result.include?(wiki_rand_and_id(@page_with_matching_title))
    assert !result.include?(wiki_rand_and_id(@page_with_matching_text))
  end

  def test_search_by_user
    User.current = User.find_by_login('rhill')
    assert User.current.memberships.empty?
    result = WikiPage.search_result_ranks_and_ids(@tokens)
    assert_includes result, wiki_rand_and_id(@page_with_matching_title)
    assert_includes result, wiki_rand_and_id(@page_with_matching_text)
  end

  def test_search_by_user_without_permission
    User.current = User.find_by_login('rhill')
    assert User.current.memberships.empty?
    remove_permission Role.non_member, :view_wiki_pages
    result = WikiPage.search_result_ranks_and_ids(@tokens)
    assert !result.include?(wiki_rand_and_id(@page_with_matching_title))
    assert !result.include?(wiki_rand_and_id(@page_with_matching_text))
  end

  def test_search_by_user_in_private_project
    User.current = User.find_by_login('rhill')
    assert User.current.memberships.empty?
    @project.update_attribute :is_public, false
    result = WikiPage.search_result_ranks_and_ids(@tokens)
    assert !result.include?(wiki_rand_and_id(@page_with_matching_title))
    assert !result.include?(wiki_rand_and_id(@page_with_matching_text))
  end

  def test_search_by_allowed_member
    User.current = User.find_by_login('jsmith')
    assert User.current.projects.include?(@project)
    result = WikiPage.search_result_ranks_and_ids(@tokens)
    assert_includes result, wiki_rand_and_id(@page_with_matching_title)
    assert_includes result, wiki_rand_and_id(@page_with_matching_text)
  end

  def test_search_by_allowed_member_in_private_project
    User.current = User.find_by_login('jsmith')
    assert User.current.projects.include?(@project)
    @project.update_attribute :is_public, false
    result = WikiPage.search_result_ranks_and_ids(@tokens)
    assert_includes result, wiki_rand_and_id(@page_with_matching_title)
    assert_includes result, wiki_rand_and_id(@page_with_matching_text)
  end

  def test_search_by_title_only
    User.current = User.find_by_login('jsmith')
    result = WikiPage.search_result_ranks_and_ids(@tokens, User.current, nil, titles_only: true)
    assert_includes result, wiki_rand_and_id(@page_with_matching_title)
    assert !result.include?(wiki_rand_and_id(@page_with_matching_text))
  end

  def test_search_by_all_words
    User.current = User.find_by_login('jsmith')
    result = WikiPage.search_result_ranks_and_ids(@tokens, User.current, nil, all_words: true)
    assert !result.include?(wiki_rand_and_id(@page_with_matching_title))
    assert !result.include?(wiki_rand_and_id(@page_with_matching_text))
    assert_includes result, wiki_rand_and_id(@page_with_matching_title_all_words)
    assert_includes result, wiki_rand_and_id(@page_with_matching_text_all_words)
  end

  private

  def wiki_rand_and_id(wiki)
    [wiki.created_on.to_i, wiki.id]
  end

  def remove_permission(role, permission)
    role.permissions = role.permissions - [ permission ]
    role.save
  end
end
