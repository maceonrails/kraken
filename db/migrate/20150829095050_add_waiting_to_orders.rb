class AddWaitingToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :waiting, :boolean, default: true
  end
end
