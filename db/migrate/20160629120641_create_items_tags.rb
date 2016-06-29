class CreateItemsTags < ActiveRecord::Migration
  def change
    create_table :items_tags do |t|
      t.references :tag, index: true, foreign_key: true
      t.references :item, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
