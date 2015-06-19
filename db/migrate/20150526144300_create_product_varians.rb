class CreateProductVarians < ActiveRecord::Migration
  def change
    create_table :product_varians, id: :uuid do |t|
      t.uuid :product_id
      t.string :name
      t.string :picture
      t.string :default_price
      t.boolean :active, default: true

      t.timestamps null: false
    end
    add_index       :product_varians, :active
    add_foreign_key :product_varians, :products
  end
end
