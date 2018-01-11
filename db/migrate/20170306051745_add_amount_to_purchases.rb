class AddAmountToPurchases < ActiveRecord::Migration
  def change
  	add_column :purchases, :amount, :float
  	add_column :purchases, :currency_code, :string
  	add_column :user_transactions, :transaction_amount, :float
  	add_column :user_transactions, :currency_code, :string
  end
end
