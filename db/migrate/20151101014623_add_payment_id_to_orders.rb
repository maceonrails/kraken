class AddPaymentIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :payment_id, :uuid
    add_index :orders, :payment_id
  end
end
