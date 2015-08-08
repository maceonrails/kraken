json.discounts @discounts do |discount|
  json.partial! 'v1/discounts/details', discount: discount
end

json.total @total