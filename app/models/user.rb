class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
   devise  :database_authenticatable, :registerable,
        :recoverable, :rememberable, :trackable, :validatable,
        :confirmable, :lockable, :timeoutable,
        :omniauthable, omniauth_providers: [:facebook, :google_oauth2]

  def self.create_from_provider_data(provider_data)
    where(provider: provider_data.provider, uid: provider_data.uid).first_or_create do | user |
      user.email = provider_data.info.email
      user.password = Devise.friendly_token[0, 20]
      user.skip_confirmation!
    end
  end

  has_many :events
  has_one :cart
  has_one :user_account
  has_many :event_videos
  has_many :solded, through: :event_videos, source: :purchases
  has_many :purchases, through: :user_transactions
  has_many :user_transactions
  has_many :static_cameras
  has_many :subscriptions
  has_many :subscribed_events, through: :subscriptions, source: :event
end
