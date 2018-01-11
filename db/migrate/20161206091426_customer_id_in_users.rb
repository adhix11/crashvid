class CustomerIdInUsers < ActiveRecord::Migration
  def change
    add_column :users,:stripe_customer_id,:text
  end
end
