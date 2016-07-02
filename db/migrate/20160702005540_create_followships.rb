class CreateFollowships < ActiveRecord::Migration
  def change
    create_table :followships do |t|
      t.references :user, index: true, foreign_key: true
      t.integer :target_user_id

      t.timestamps null: false
    end

    add_index :followships, :target_user_id
  end
end
