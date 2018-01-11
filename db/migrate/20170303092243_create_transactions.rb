class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.integer :user_id
      t.integer :purchase_id
      t.text :paykey
      t.string :sender_mail_id
      t.text :sender_account_id
      t.text :primary_transaction_id
      t.string :primary_transaction_status
      t.text :secondary_transaction_id
      t.string :secondary_transaction_status
      t.string :transaction_status

      t.timestamps null: false
    end
  end
end
