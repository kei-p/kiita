class Stock < ActiveRecord::Base
  belongs_to :user
  belongs_to :item
  counter_culture :item

  validates :item, uniqueness: { scope: [:user_id] }
end
