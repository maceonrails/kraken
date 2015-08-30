class RemoveProductCategoryIdFromProducts < ActiveRecord::Migration
  def change
  	remove_column :products, :product_category_id
  end
end
