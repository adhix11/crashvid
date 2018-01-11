class VideoInEventVideo < ActiveRecord::Migration
  def change
    add_column :event_videos,:video,:text
  end
end
