class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, omniauth_providers: [:twitter]

  has_many :items
  has_many :stocks
  has_many :stock_items, through: :stocks, source: :item

  validates :name, presence: true

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
end
