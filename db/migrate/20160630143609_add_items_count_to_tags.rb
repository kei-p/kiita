class AddItemsCountToTags < ActiveRecord::Migration
  def change
  	add_column :tags, :items_count, :integer, default: 0
  end
end
