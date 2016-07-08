class AddColumnPublishedAtToItems < ActiveRecord::Migration
  def up
    add_column :items, :published_at, :datetime
    Item.update_all 'published_at=created_at'
  end

  def down
    remove_column :items, :published_at, :datetime
  end
end
