class EventVideo < ActiveRecord::Base
  mount_uploader :video, VideoUploader
  belongs_to :event
  belongs_to :user
  has_many :cart_items
  has_many :spam
  has_many :purchases
end
