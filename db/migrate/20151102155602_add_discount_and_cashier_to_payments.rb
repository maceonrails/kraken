class AddDiscountAndCashierToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :discount_amount, :string
    add_column :payments, :discount_percent, :string
    add_column :payments, :discount_by, :uuid
    add_column :payments, :cashier_id, :uuid
  end
end
