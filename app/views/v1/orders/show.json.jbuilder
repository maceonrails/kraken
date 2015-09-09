json.extract! @order, :id, :name, :waiting, :queue_number, :table_id, :servant_id
json.order_items @order.get_active_items do |item|
	json.merge! item.attributes
	json.price item.product.price
	json.name item.product.name
end