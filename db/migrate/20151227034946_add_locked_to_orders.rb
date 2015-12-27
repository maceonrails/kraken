class AddLockedToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :locked, :boolean, default: false
  end
end
