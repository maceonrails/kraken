class AddCardDetailToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :debit_amount, :string
    add_column :orders, :credit_amount, :string
    add_column :orders, :cash_amount, :string
    add_column :orders, :debit_name, :string
    add_column :orders, :debit_number, :string
    add_column :orders, :credit_name, :string
    add_column :orders, :credit_number, :string
  end
end
