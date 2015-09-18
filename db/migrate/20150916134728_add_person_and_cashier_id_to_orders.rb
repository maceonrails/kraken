class AddPersonAndCashierIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :person, :integer
    add_column :orders, :cashier_id, :integer
  end
end
