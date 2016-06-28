class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, omniauth_providers: [:twitter]

  has_many :items

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
end
