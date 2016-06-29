class Item < ActiveRecord::Base
  attr_accessor :tags_name_notation
  belongs_to :user

  has_and_belongs_to_many :tags

  after_initialize do
    self.tags_name_notation ||= self.tags.map(&:name).join(' ')
  end

  after_save do
    self.tags = Tag.find_or_initialize_by_name_notation(tags_name_notation) if tags_name_notation
  end
end
