class ChangeCashierIdInOrder < ActiveRecord::Migration
  def change
  	remove_column :orders, :cashier_id
  	add_column :orders, :cashier_id, :uuid
  end
end
