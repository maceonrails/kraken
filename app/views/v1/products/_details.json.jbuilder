json.id             product.id
json.name           product.name
json.description    product.description
json.category       product.product_sub_category.name
json.default_price  product.default_price
json.price          product.price
json.picture        request.protocol + request.host_with_port + product.picture
json.created_at     product.created_at
json.updated_at     product.updated_at