class CreateProductSubCategories < ActiveRecord::Migration
  def change
    create_table :product_sub_categories, id: :uuid do |t|
      t.uuid :product_category_id
      t.string :name
      t.boolean :valid

      t.timestamps null: false
    end
  end
end
