class Item < ActiveRecord::Base
  attr_accessor :publish, :tag_names
  belongs_to :user

  has_many :items_tags, dependent: :destroy
  has_many :tags, through: :items_tags
  has_many :stocks, dependent: :destroy

  validates :user, presence: true
  validates :title, presence: true
  validates :body, presence: true
  validate :protect_update_search_column, unless: proc { [:update_search_column].include?(validation_context) }
  after_save :update_tags, if: proc { |item| item.tag_names.present? }

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

  def published?
    published_at.present?
  end

  def current_tag_names
    tags.map(&:name).join(' ')
  end

  private

  def self.enclosed_tag_name(tag_name)
    "'#{tag_name}'"
  end

  def protect_update_search_column
    errors.add(:tags_name_notation, 'は編集できません') if tags_name_notation_changed?
  end

  def update_tags
    old_tags = tags.to_a
    new_tags = Tag.find_or_initialize_by_name_notation(tag_names).to_a
    self.tag_names = nil

    (old_tags - new_tags).each do |tag|
      items_tags.find_by(tag: tag).destroy
    end

    (new_tags - old_tags).each do |tag|
      items_tags.create(tag: tag)
    end

    enclosed_tag_names = new_tags.map { |t| self.class.enclosed_tag_name(t.name) }.join(' ')
    self.tags_name_notation = enclosed_tag_names
    save(context: :update_search_column)
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
        result[:tag]  << enclosed_tag_name(s[:tag_name])
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
