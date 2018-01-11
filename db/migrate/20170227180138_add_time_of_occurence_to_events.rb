class AddTimeOfOccurenceToEvents < ActiveRecord::Migration
  def change
    add_column :events, :time_of_occurence, :string
  end
end
