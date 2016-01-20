json.products @products do |product|
  json.id                 product.id
  json.name               product.name
  json.description        product.description
  json.category           product.product_sub_category.name
  json.default_price      product.default_price
  json.price              product.try(:price)
  if product.picture.present?
    json.picture          request.protocol + request.host_with_port + product.picture.to_s
  else
    json.picture          request.protocol + request.host_with_port + '/placeholder/no-image.png'
  end

  json.created_at         product.created_at
  json.updated_at         product.updated_at
  json.choices            product.choices
  json.available          product.available
  json.serv_category      product.product_category.try(:name)
  json.serv_sub_category  product.product_sub_category.name
  json.tenant_id          product.tenant_id
  json.sold_out           product.sold_out
  json.discounts          product.discounts.active   do |dsc|
    json.id               dsc.id
    json.name             dsc.name
    json.created_at       dsc.created_at
    json.updated_at       dsc.updated_at
    json.updated_by       dsc.updated_by
    json.start_date       dsc.start_date
    json.end_date         dsc.end_date
    json.start_time       dsc.start_time
    json.end_time         dsc.end_time
    json.days             dsc.days
    json.amount           dsc.percentage.to_i > 0 ? (product.price.to_i * dsc.percentage.to_i / 100) : dsc.amount.to_i
    json.percentage       dsc.percentage
  end
end

json.total @products.first.total if @products.first