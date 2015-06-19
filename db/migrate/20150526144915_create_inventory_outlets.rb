class CreateInventoryOutlets < ActiveRecord::Migration
  def change
    create_table :inventory_outlets do |t|
      t.uuid :outlet_id
      t.uuid :inventory_id

      t.timestamps null: false
    end
    add_foreign_key :inventory_outlets, :outlets
    add_foreign_key :inventory_outlets, :inventories
  end
end
