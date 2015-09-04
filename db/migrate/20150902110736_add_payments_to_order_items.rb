class AddPaymentsToOrderItems < ActiveRecord::Migration
  def change
    add_column :order_items, :paid, :boolean, default: false
    add_column :order_items, :paid_amount, :decimal, :precision => 10, :scale => 2
    add_column :order_items, :tax_amount, :decimal, :precision => 10, :scale => 2
    add_column :order_items, :discount_amount, :decimal, :precision => 5, :scale => 2
    add_column :order_items, :void_note, :string
    add_column :order_items, :void_quantity, :integer, default: 0
  end
end
