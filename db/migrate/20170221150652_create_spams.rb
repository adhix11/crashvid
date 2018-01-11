class CreateSpams < ActiveRecord::Migration
  def change
    create_table :spams do |t|
      t.string :spam_category
      t.text :comment
      t.integer :user_id
      t.integer :event_video_id

      t.timestamps null: false
    end
  end
end
