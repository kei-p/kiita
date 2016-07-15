class Tag < ActiveRecord::Base
  has_and_belongs_to_many :items

  validates :name, presence: true, uniqueness: true

  def fix_items_count
    update(items_count: items.published.count)
  end

  def self.find_or_initialize_by_name_notation(notation)
    notation.split(' ').map do |name|
      find_or_initialize_by(name: name)
    end
  end
end
