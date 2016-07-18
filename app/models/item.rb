class Item < ActiveRecord::Base
  attr_accessor :publish
  belongs_to :user

  has_many :items_tags
  has_many :tags, through: :items_tags
  has_many :stocks

  validates :user, presence: true
  validates :title, presence: true
  validates :body, presence: true

  scope :draft, -> { where(published_at: nil) }
  scope :published, -> { where.not(published_at: nil) }

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
    update_tags
  end

  def published?
    published_at.present?
  end

  def current_tags_name_notation
    tags.map(&:name).join(' ')
  end

  private

  def update_tags
    old_tags = tags.to_a
    new_tags = Tag.find_or_initialize_by_name_notation(tags_name_notation).to_a

    (old_tags - new_tags).each do |tag|
      items_tags.find_by(tag: tag).destroy
    end

    (new_tags - old_tags).each do |tag|
      items_tags.create(tag: tag)
    end
  end

  REGEXP_USER_WITH_QUOTATION = /user:["'](?<user_name>.*?)["'](\s|$)/
  REGEXP_USER = /user:(?<user_name>[^\s]*?)(\s|$)/
  REGEXP_TAG = /tag:(?<tag_name>[^\s]*?)(\s|$)/
  REGEXP_WORD = /(?<word>[^\s]+?)(\s|$)/
  REGEXP_BLANK = /\s+/
  def self.parse_query(q)
    s = StringScanner.new(q)
    result = { title: [] , user: [], tag: []}
    until s.eos?
      case
      when s.scan(REGEXP_USER_WITH_QUOTATION)
        result[:user] << s[:user_name]
      when s.scan(REGEXP_USER)
        result[:user] << s[:user_name]
      when s.scan(REGEXP_TAG)
        result[:tag]  << s[:tag_name]
      when s.scan(REGEXP_WORD)
        result[:title]  << s[:word]
      when s.scan(REGEXP_BLANK)
      else
        break
      end
    end
    {
      title_cont_all: result[:title],
      tags_name_notation_cont_all: result[:tag],
      user_name_eq: result[:user].first
    }
  end
end
