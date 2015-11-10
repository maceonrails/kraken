class AddPaymentAmountToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :debit_amount, :string
    add_column :payments, :credit_amount, :string
    add_column :payments, :cash_amount, :string
    add_column :payments, :debit_name, :string
    add_column :payments, :credit_name, :string
    add_column :payments, :debit_number, :string
    add_column :payments, :credit_number, :string
  end
end
