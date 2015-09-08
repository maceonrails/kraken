class AddPayQuantityToOrderItems < ActiveRecord::Migration
  def change
    add_column :order_items, :pay_quantity, :integer, default: 0
  end
end
