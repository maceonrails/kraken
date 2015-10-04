class CreateProductDiscounts < ActiveRecord::Migration
  def change
    create_table :product_discounts do |t|
      t.uuid :product_id, index: true
      t.references :discount, index: true

      t.timestamps null: false
    end
    add_foreign_key :product_discounts, :discounts
    add_foreign_key :product_discounts, :products
  end
end
