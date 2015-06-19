class CreateProductCategories < ActiveRecord::Migration
  def change
    create_table :product_categories, id: :uuid do |t|
      t.uuid :company_id
      t.string :name
      t.boolean :valid

      t.timestamps null: false
    end
    add_foreign_key :product_categories, :companies
  end
end
