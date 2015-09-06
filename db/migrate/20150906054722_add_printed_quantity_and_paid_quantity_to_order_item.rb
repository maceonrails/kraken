class AddPrintedQuantityAndPaidQuantityToOrderItem < ActiveRecord::Migration
  def change
    add_column :order_items, :paid_quantity, :integer
    add_column :order_items, :printed_quantity, :integer
  end
end
