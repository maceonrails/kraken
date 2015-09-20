class AddStruckIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :struck_id, :string
  	add_index :orders, :struck_id
  end

end
