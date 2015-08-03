json.products @products do |product|
  json.partial! 'v1/products/details', product: product
end

json.total @products.first.total if @products.first