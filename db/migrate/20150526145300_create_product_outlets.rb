class CreateProductOutlets < ActiveRecord::Migration
  def change
    create_table :product_outlets do |t|
      t.uuid :outlet_id
      t.uuid :product_id

      t.timestamps null: false
    end
    add_foreign_key :product_outlets, :outlets
    add_foreign_key :product_outlets, :products
  end
end
