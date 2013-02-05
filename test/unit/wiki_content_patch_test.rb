require File.expand_path('../../test_helper', __FILE__)

class WikiContentPatchTest < ActiveSupport::TestCase
  fixtures :wikis, :wiki_pages

  def setup
    @wiki = Wiki.find(1)
    @page = @wiki.pages.first
  end

  def test_wiki_content_encrypts_text_in_database
    content = WikiContent.create(page: @page, text: "Hello world!")
    content_result = ActiveRecord::Base.connection.
        execute("SELECT * FROM #{WikiContent.table_name} WHERE id = #{content.id}").first
    assert !content_result['encrypted_text'].blank?, 'encrypted text should not be blank'
    assert content_result['encrypted_text'] != "Hello world!", 'encrypted text should not equal to source text'
    assert content_result['text'].blank?, "text should be blank"
  end

  def test_wiki_content_decrypts_text
    content = WikiContent.create(page: @page, text: "Hello world!")
    loaded_content = WikiContent.find(content.id)
    assert loaded_content.text == "Hello world!"
  end
end
