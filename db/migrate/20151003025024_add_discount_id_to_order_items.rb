class AddDiscountIdToOrderItems < ActiveRecord::Migration
  def change
    add_reference :order_items, :discount, index: true
    add_foreign_key :order_items, :discounts
  end
end
