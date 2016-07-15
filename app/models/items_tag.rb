class ItemsTag < ActiveRecord::Base
  belongs_to :tag
  belongs_to :item
  counter_culture :tag, column_name: :items_count, delta_magnitude: proc { |model| model.item.published? ? 1 : 0 }

  validates :item, uniqueness: { scope: [:tag_id] }
end
