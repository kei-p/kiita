class AddColumnStocksCountToItems < ActiveRecord::Migration
  def change
  	add_column :items, :stocks_count, :integer, default: 0
  end
end
