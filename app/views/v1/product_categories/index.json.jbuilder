json.product_categories @product_categories do |product_category|
  json.extract! product_category, :id, :name 
  json.product_sub_categories product_category.product_sub_categories
end

