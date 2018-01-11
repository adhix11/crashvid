class EventVideoPrice < ActiveRecord::Migration
  def change
    add_column :event_videos,:price,:integer,:default => 20
  end
end
