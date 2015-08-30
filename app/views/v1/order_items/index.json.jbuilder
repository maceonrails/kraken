json.orders @orders do |order|
  json.extract! order, :id, :name, :waiting
  json.order_items order.order_items
end

