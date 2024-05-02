require File.expand_path('../../test_helper', __FILE__)

class WikiEncryptorTest < ActiveSupport::TestCase
  fixtures :wikis, :wiki_pages, :wiki_contents, :wiki_content_versions

  def test_encrypts_existing_wiki_contents
    content = WikiContent.first
    WikiEncryptor.encrypt
    encrypted_content_result = ActiveRecord::Base.connection.
        execute("SELECT * FROM #{WikiContent.table_name} WHERE id = #{content.id}").first
    assert encrypted_content_result['text'].blank?, 'text should be blank'
    assert !encrypted_content_result['encrypted_text'].blank?, 'encrypted text should not be blank'
  end

  def test_encrypts_existing_wiki_content_versions
    content_version = WikiContent.first.versions.first
    WikiEncryptor.encrypt
    encrypted_version = WikiContentVersion.find(content_version.id)
    assert encrypted_version.attributes['data'] != content_version.attributes['data']
  end

  def test_decrypts_encrypted_wiki_contents
    encrypted_content = WikiContent.create(page: Wiki.first.pages.first, text: "Hello world!")
    WikiEncryptor.decrypt
    decrypted_content_result = ActiveRecord::Base.connection.
        execute("SELECT * FROM #{WikiContent.table_name} WHERE id = #{encrypted_content.id}").first
    assert decrypted_content_result['text'] == "Hello world!", "text should equal to source text"
    assert decrypted_content_result['encrypted_text'].blank?, "encrypted text should be blank"
  end

  def test_decrypts_encrypted_wiki_content_versions
    encrypted_content = WikiContent.create(page: Wiki.first.pages.first, text: "Hello world!")
    WikiEncryptor.decrypt
    encrypted_content.reload
    assert encrypted_content.versions.first['data'] == "Hello world!"
  end

end
