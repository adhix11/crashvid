class RenameStripeUserIdToPaypalPaykey < ActiveRecord::Migration
  def change
  	 rename_column :users, :stripe_user_id, :paypal_paykey
  end
end
