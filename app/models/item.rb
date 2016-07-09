class Item < ActiveRecord::Base
  attr_accessor :publish
  belongs_to :user

  has_and_belongs_to_many :tags
  has_many :stocks

  validates :user, presence: true
  validates :title, presence: true
  validates :body, presence: true

  scope :draft, -> { where(published_at: nil) }
  scope :published, -> { where.not(published_at: nil) }
  scope :search, -> (query) {
    q = parse_query(query)
    if q.values.any?(&:present?)
      published.search_by_title(q[:title])
               .search_by_user(q[:user])
               .search_by_tag(q[:tag])
    else
      none
    end
  }

  scope :search_by_title, -> (words) {
    conditions = words.map { |w| "title LIKE \'%#{w}%\'" }.join(" AND ")
    where(conditions)
  }

  scope :search_by_user, -> (user_names) {
    user_names.empty? ? where(nil) : joins(:user).where(users: { name: user_names.first })
  }

  scope :search_by_tag, -> (tag_names) {
    conditions = tag_names.map { |w| "tags_name_notation REGEXP \'(^|\s)#{w}(\s|$)\'" }.join(" AND ")
    where(conditions)
  }

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
    if tags_name_notation_changed?
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

  def current_tags_name_notation
    tags.map(&:name).join(' ')
  end

  private

  REGEXP_USER = /\Auser:/
  REGEXP_TAG = /\Atag:/
  def self.parse_query(q)
    q.split(' ').each_with_object({ title: [] , user: [], tag: []}) do |w, h|
      case w
      when REGEXP_USER
        h[:user] << w.sub(REGEXP_USER, '')
      when REGEXP_TAG
        h[:tag] << w.sub(REGEXP_TAG, '')
      else
        h[:title] << w
      end
    end
  end
end
