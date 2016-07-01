class Item < ActiveRecord::Base
  attr_accessor :tags_name_notation
  belongs_to :user

  has_and_belongs_to_many :tags
  has_many :stocks

  validates :user, presence: true
  validates :title, presence: true
  validates :body, presence: true

  def tags_name_notation
    @tags_name_notation || current_tags_name_notation
  end

  after_save do
    unless tags_name_notation == current_tags_name_notation
      @tmp_tags = tags.to_a
      self.tags = Tag.find_or_initialize_by_name_notation(tags_name_notation)
      update_tags_items_count
    end
  end

  def update_tags_items_count
    [@tmp_tags, tags].flatten.uniq.each do |tag|
      tag.update(items_count: tag.items.count)
    end
  end

  def update_stocks_count
    update(stocks_count: stocks.count)
  end

  private

  def current_tags_name_notation
    tags.map(&:name).join(' ')
  end
end
