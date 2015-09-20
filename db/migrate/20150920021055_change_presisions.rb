class ChangePresisions < ActiveRecord::Migration
  def change
    remove_column :products, :price
    remove_column :products, :default_price
    remove_column :payments, :amount
    remove_column :payments, :discount
    remove_column :orders, :discount_amount
    remove_column :orders, :discount_percent
    remove_column :order_items, :paid_amount
    remove_column :order_items, :tax_amount
    remove_column :order_items, :discount_amount
    add_column :products, :price,               :decimal, :precision => 25, :scale => 2
    add_column :products, :default_price,       :decimal, :precision => 25, :scale => 2
    add_column :payments, :amount,              :decimal, :precision => 25, :scale => 2
    add_column :payments, :discount,            :decimal, :precision => 25, :scale => 2
    add_column :orders, :discount_amount,       :decimal, :precision => 25, :scale => 2
    add_column :orders, :discount_percent,      :decimal, :precision => 25, :scale => 2
    add_column :order_items, :paid_amount,      :decimal, :precision => 25, :scale => 2
    add_column :order_items, :tax_amount,       :decimal, :precision => 25, :scale => 2
    add_column :order_items, :discount_amount,  :decimal, :precision => 25, :scale => 2
  end
end
