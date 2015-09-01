class AddQueueNumberToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :queue_number, :integer
  end
end
