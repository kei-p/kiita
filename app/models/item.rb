class Item < ActiveRecord::Base
  attr_accessor :tags_name_notation, :publish
  belongs_to :user

  has_and_belongs_to_many :tags
  has_many :stocks

  validates :user, presence: true
  validates :title, presence: true
  validates :body, presence: true

  scope :draft, -> { where(published_at: nil) }
  scope :published, -> { where.not(published_at: nil) }
  scope :search, -> (query) {
    if query.present?
      published.where('title LIKE ?', "%#{query}%")
    else
      none
    end
  }


  def tags_name_notation
    @tags_name_notation || current_tags_name_notation
  end

  def true?(txt)
    case txt
    when "1", "true", true
      true
    else
      false
    end
  end

  before_save do
    self.published_at = Time.zone.now if true?(publish) && !published?
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

  def published?
    published_at.present?
  end

  private

  def current_tags_name_notation
    tags.map(&:name).join(' ')
  end
end
