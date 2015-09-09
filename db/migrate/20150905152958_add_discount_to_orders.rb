class AddDiscountToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :discount_amount, :decimal, :precision => 10, :scale => 2
    add_column :orders, :discount_percent, :decimal, :precision => 5, :scale => 2
    add_column :orders, :discount_by, :uuid
  end
end
