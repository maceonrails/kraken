json.order_items @order_items do |order_item|
  json.extract! order_item, :id, :quantity, :note, :served, :void, :paid, :paid_amount, :tax_amount, :discount_amount
  json.choice order_item.choice
  json.order order_item.order
  json.product order_item.product

end

