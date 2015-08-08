json.discount do
  json.partial! 'v1/discounts/details', discount: @discount
end