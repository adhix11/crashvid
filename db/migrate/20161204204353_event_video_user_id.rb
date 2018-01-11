class EventVideoUserId < ActiveRecord::Migration
  def change
    add_column :event_videos,:user_id,:integer
  end
end
