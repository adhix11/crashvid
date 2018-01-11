class StripeUserId < ActiveRecord::Migration
  def change
    add_column :users,:stripe_user_id,:text
  end
end
