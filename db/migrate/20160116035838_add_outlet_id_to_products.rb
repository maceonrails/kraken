class AddOutletIdToProducts < ActiveRecord::Migration
  def change
    add_column :products, :outlet_id, :uuid
    add_column :orders, :outlet_id, :uuid
    add_column :payments, :outlet_id, :uuid
  end
end
