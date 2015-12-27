class DeletePaymentInfoInOrders < ActiveRecord::Migration
  def change
		remove_column :orders, :debit_amount
		remove_column :orders, :credit_amount
		remove_column :orders, :cash_amount
		remove_column :orders, :debit_name
		remove_column :orders, :debit_number
		remove_column :orders, :credit_name
		remove_column :orders, :credit_number
  end
end
