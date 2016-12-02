class AddNotIndexToWikiPages < ActiveRecord::Migration
  def change
    add_column WikiPage.table_name, :not_index, :boolean, default: false
  end
end
