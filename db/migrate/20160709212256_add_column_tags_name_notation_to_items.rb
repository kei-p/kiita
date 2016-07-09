class AddColumnTagsNameNotationToItems < ActiveRecord::Migration
  def up
    add_column :items, :tags_name_notation, :string

    Item.published.each { |i| i.update(tags_name_notation: i.current_tags_name_notation) }
  end

  def down
    remove_column :items, :tags_name_notation, :string
  end
end
