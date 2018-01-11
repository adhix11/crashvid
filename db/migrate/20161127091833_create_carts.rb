class CreateCarts < ActiveRecord::Migration
  def change
    create_table :carts do |t|
      t.integer :event_video_id
      t.float :price
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
