class AddColumnProfileToUser < ActiveRecord::Migration
  def change
    add_column :users, :profile, :text
  end
end
