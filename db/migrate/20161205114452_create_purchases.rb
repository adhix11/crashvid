class CreatePurchases < ActiveRecord::Migration
  def change
    create_table :purchases do |t|
      t.integer :user_id
      t.integer :event_video_id
      t.text :stripe_charge_id

      t.timestamps null: false
    end
  end
end
