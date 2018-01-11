class RenameAddressToAddressLine1 < ActiveRecord::Migration
  def change
  	rename_column :user_accounts, :address, :address_line_1
  end
end
