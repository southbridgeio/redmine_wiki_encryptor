class AddEncryptedTextToWikiContentVersions < Rails.version < '5.0' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
  def change
    if ActiveRecord::Base.connection.adapter_name  == 'Mysql2'
      add_column WikiContentVersion.table_name, :encrypted_text, :text, limit: 4294967295
      add_column WikiContentVersion.table_name, :encrypted_text_iv, :text
    else
      add_column WikiContentVersion.table_name, :encrypted_text, :text
      add_column WikiContentVersion.table_name, :encrypted_text_iv, :text
    end
  end
end
