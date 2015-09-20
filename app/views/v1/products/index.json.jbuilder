json.products @products do |product|
  json.id             product.id
  json.name           product.name
  json.description    product.description
  json.category       product.product_sub_category.name
  json.default_price  product.default_price
  json.price          product.price - product.active_discount.try(:amount).to_i rescue 0
  json.discount       product.active_discount.try(:amount).to_i
  json.default_price  product.price
  json.picture        request.protocol + request.host_with_port + product.picture
  json.created_at     product.created_at
  json.updated_at     product.updated_at
  json.choices        product.choices
  json.available      product.available
  json.serv_category  product.product_sub_category.product_category.name
  json.serv_sub_category  product.product_sub_category.name
  json.sold_out       product.sold_out
end

json.total @products.first.total if @products.first