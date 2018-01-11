class CreateStaticCameras < ActiveRecord::Migration
  def change
    create_table :static_cameras do |t|
      t.float :latitude
      t.float :longitude
      t.integer  :user_id,           limit: 4
   	  t.string   :location_name,     limit: 255
      t.string   :place_id,          limit: 255
      t.timestamps null: false
    end
  end
end
