class AddSubCategoryIdToProducts < ActiveRecord::Migration
  def change
    add_column :products, :product_sub_category_id, :uuid
  end
end
