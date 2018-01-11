class ChangeTimeOfOccurenceFormatInEvents < ActiveRecord::Migration
  def change
  	change_column :events, :time_of_occurence, :time
  end
end
