class DropCustomerIdAccessTokenInUsers < ActiveRecord::Migration
  def change
    remove_column :users,:stripe_customer_id
    remove_column :users,:card_token
    remove_column :users,:stripe_publishable_key
    remove_column :users,:stripe_access_token
  end
end
