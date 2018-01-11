class StaticCamera < ActiveRecord::Base
  acts_as_mappable :default_units => :miles,:default_formula => :sphere, :lat_column_name => :latitude, :lng_column_name => :longitude
  belongs_to :user
  validates_presence_of :latitude
  validates_presence_of :longitude
end
