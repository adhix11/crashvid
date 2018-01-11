class RenameColumnInPurchases < ActiveRecord::Migration
  def change
  	rename_column :purchases, :transaction_id, :user_transaction_id
  end
end
