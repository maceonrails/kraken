json.categories @categories do |category|
	json.id category.id
	json.name category.name
	json.sub_categories category.product_sub_categories
end