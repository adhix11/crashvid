class RenameTransactionToUserTransaction < ActiveRecord::Migration
  def change
  	rename_table :transactions, :user_transactions
  end
end
