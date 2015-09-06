class AddPrintedQuantityAndPaidQuantityToOrderItem < ActiveRecord::Migration
  def change
    add_column :order_items, :paid_quantity, :integer, default: 0
    add_column :order_items, :printed_quantity, :integer, default: 0
  end
end
