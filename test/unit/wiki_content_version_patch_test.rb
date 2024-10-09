require File.expand_path('../../test_helper', __FILE__)

class WikiContentVersionPatchTest < ActiveSupport::TestCase
  fixtures :wikis, :wiki_pages

  def setup
    @wiki = Wiki.find(1)
    @page = @wiki.pages.first
  end

  def test_wiki_content_version_encrypts_data_in_database
    content = WikiContent.create(page: @page, text: "Hello world!")
    assert content.versions.first['data'] != "Hello world!", 'data should not equal to source text'
  end

  def test_wiki_content_version_decrypts_text
    content = WikiContent.create(page: @page, text: "Hello world!")
    loaded_content = WikiContent.find(content.id)
    assert loaded_content.versions.first.text == "Hello world!"
  end

end
