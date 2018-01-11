class UserTransaction < ActiveRecord::Base
	has_many :purchases
	belongs_to :user
end
