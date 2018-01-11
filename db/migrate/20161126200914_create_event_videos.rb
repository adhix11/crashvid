class CreateEventVideos < ActiveRecord::Migration
  def change
    create_table :event_videos do |t|
      t.text :name
      t.text :location

      t.timestamps null: false
    end
  end
end
