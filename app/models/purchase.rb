class Purchase < ActiveRecord::Base
  belongs_to :user
  belongs_to :user_transaction
  belongs_to :event_video
end
