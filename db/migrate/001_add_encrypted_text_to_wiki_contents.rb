class AddEncryptedTextToWikiContents < ActiveRecord::Migration
  def change
    if ActiveRecord::Base.connection.adapter_name  == 'Mysql2'
      add_column WikiContent.table_name, :encrypted_text, :text, limit: 4294967295
    else
      add_column WikiContent.table_name, :encrypted_text, :text
    end
  end
end
