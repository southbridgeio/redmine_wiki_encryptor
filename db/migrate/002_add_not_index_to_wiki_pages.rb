class AddNotIndexToWikiPages < Rails.version < '5.0' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
  def change
    add_column WikiPage.table_name, :not_index, :boolean, default: false
  end
end
