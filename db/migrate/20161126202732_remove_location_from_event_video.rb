class RemoveLocationFromEventVideo < ActiveRecord::Migration
  def change
    remove_column :event_videos,:location
  end
end
