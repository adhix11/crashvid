class RemovePurchaseIdFromTransactions < ActiveRecord::Migration
  def change
  	remove_column :transactions, :purchase_id
  	add_column :purchases, :transaction_id, :text
  end
end
