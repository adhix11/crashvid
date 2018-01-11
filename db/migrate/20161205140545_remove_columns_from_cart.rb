class RemoveColumnsFromCart < ActiveRecord::Migration
  def change
    remove_column :carts,:event_video_id
    remove_column :carts,:price
  end
end
