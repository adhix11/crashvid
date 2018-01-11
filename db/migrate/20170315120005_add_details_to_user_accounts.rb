class AddDetailsToUserAccounts < ActiveRecord::Migration
  def change
    add_column :user_accounts, :address_line_2, :string
    add_column :user_accounts, :city, :string
    add_column :user_accounts, :zipcode, :decimal
    add_column :user_accounts, :country, :string
  end
end
