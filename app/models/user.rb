class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, omniauth_providers: [:twitter]

  has_many :items
  has_many :stocks
  has_many :stock_items, through: :stocks, source: :item

  has_many :following_followships, class_name: 'Followship', foreign_key: :user_id
  has_many :followings, through: :following_followships, source: :target_user

  has_many :follower_followships, class_name: 'Followship', foreign_key: :target_user_id
  has_many :followers, through: :follower_followships, source: :user

  validates :name, presence: true

  has_many :draft_items, -> { draft }, class_name: Item
  has_many :published_items, -> { published }, class_name: Item

  def self.find_or_initialize_by_oauth(oauth)
    find_or_initialize_by(
      provider: oauth.provider,
      uid: oauth.uid,
    )
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.twitter_data"]
        user.provider = data["provider"]
        user.uid = data["uid"]
        user.name = data["info"]["name"]
        user.icon_url = data["info"]["image"]
      end
    end
  end

  def set_oauth(oauth)
    self.provider = oauth.provider
    self.uid = oauth.uid
  end

  def password_required?
    new_record? && ( !oauthorized? )
  end

  def oauthorized?
    provider.present? && uid.present?
  end

  def stock(item)
    stocks.create(item: item)
  end

  def stock?(item)
    stock_items.include? item
  end

  def unstock(item)
    stocks.find_by(item: item).destroy
  end

  def follow(user)
    following_followships.create(target_user: user)
  end

  def follow?(user)
    followings.include?(user)
  end

  def unfollow(user)
    following_followships.find_by(target_user: user).destroy
  end

  def feed
    following_ids = followings.pluck(:id)
    Item.all.published.where(user: following_ids)
  end
end
