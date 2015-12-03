class AddAmountToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :sub_total, :decimal, :precision => 20, :scale => 2
    add_column :payments, :total, :decimal, :precision => 20, :scale => 2
    add_column :payments, :pay_amount, :decimal, :precision => 20, :scale => 2
    remove_column :payments, :cash_amount
    remove_column :payments, :credit_amount
    remove_column :payments, :debit_amount
    add_column :payments, :cash_amount, :decimal, :precision => 20, :scale => 2
    add_column :payments, :credit_amount, :decimal, :precision => 20, :scale => 2
    add_column :payments, :debit_amount, :decimal, :precision => 20, :scale => 2
  end
end
