class PaymentStatusInPurchase < ActiveRecord::Migration
  def change
    add_column :purchases,:payment_status,:string
  end
end
