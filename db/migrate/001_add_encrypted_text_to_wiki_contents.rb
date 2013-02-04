class AddEncryptedTextToWikiContents < ActiveRecord::Migration
  def change
    add_column WikiContent.table_name, :encrypted_text, :text
  end
end
