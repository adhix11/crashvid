class Event < ActiveRecord::Base
  acts_as_taggable_on :categories
  acts_as_mappable :default_units => :miles,:default_formula => :sphere, :lat_column_name => :latitude, :lng_column_name => :longitude
  has_many :event_videos
  belongs_to :user
  has_many :subscriptions
  has_many :subscribed_users, through: :subscriptions, source: :user
  validates_presence_of :latitude
  validates_presence_of :longitude
  validates_presence_of :date_of_occurence

end
