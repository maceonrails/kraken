class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products, id: :uuid do |t|
      t.uuid :company_id
      t.uuid :product_category_id
      t.string :name
      t.string :picture
      t.boolean :active, default: true
      t.string :default_price

      t.timestamps null: false
    end
    add_index       :products, :active
    add_foreign_key :products, :companies
    add_foreign_key :products, :product_categories
  end
end
