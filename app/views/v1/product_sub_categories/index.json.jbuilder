json.product_sub_categories @product_sub_categories do |spc|
  json.extract! spc, :id, :name
end

