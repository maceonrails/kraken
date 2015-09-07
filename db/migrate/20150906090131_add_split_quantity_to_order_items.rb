class AddSplitQuantityToOrderItems < ActiveRecord::Migration
  def change
    add_column :order_items, :split_quantity, :integer, default: 0
  end
end
