class AddEventIdToEventVideos < ActiveRecord::Migration
  def change
    add_column :event_videos,:event_id,:integer
  end
end
