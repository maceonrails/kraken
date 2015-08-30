class ChangePriceTypeInProducts < ActiveRecord::Migration
  def change
  	remove_column :products, :price
  	remove_column :products, :default_price
  	add_column :products, :price, :decimal, :precision => 10, :scale => 2
  	add_column :products, :default_price, :decimal, :precision => 10, :scale => 2
  end
end
