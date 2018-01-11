class ChangeColumnNameInPurchase < ActiveRecord::Migration
  def change
  	rename_column :purchases, :stripe_charge_id, :paypal_paykey
  end
end
