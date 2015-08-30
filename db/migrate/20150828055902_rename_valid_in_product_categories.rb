class RenameValidInProductCategories < ActiveRecord::Migration
  def change
  	rename_column :product_categories, :valid, :is_valid
  	rename_column :product_sub_categories, :valid, :is_valid
  end
end
