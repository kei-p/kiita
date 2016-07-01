class Stock < ActiveRecord::Base
  belongs_to :user
  belongs_to :item

  validates :item, uniqueness: { scope: [:user_id] }

  after_create do
    item.update_stocks_count
  end

  after_destroy do
    item.update_stocks_count
  end
end
