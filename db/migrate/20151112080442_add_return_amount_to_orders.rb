class AddReturnAmountToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :return_amount, :string, default: '0.0'
  end
end
