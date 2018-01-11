class Cart < ActiveRecord::Base
  belongs_to :user
  has_many :cart_items
  has_many :event_videos,:through => :cart_items
end
