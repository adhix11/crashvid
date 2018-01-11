class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.float :latitude
      t.float :longitude
      t.datetime :date_of_occurence

      t.timestamps null: false
    end
  end
end
