class AddEncryptedTextToWikiContents < ActiveRecord::Migration
  def change
    add_column :wiki_contents, :encrypted_text, :text
  end
end
