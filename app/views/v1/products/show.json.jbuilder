json.product do
  json.partial! 'v1/products/details', product: @product
end