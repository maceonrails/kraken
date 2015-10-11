json.extract! @order, :id, :name, :waiting, :queue_number, :table_id, :servant_id, :struck_id, :discount_amount, :discount_percent
json.table_name @order.table.try(:name)
json.table_location @order.table.try(:location)
json.order_items @order.get_active_items do |item|
	json.merge! 				item.attributes
	json.price 					item.product.price - item.discount.try(:amount).to_i
	json.default_price 	item.product.price
	json.name 					item.product.name
	json.discount 			item.discount
	json.product do
		json.choices item.product.choices
		json.discounts item.product.discounts
	end
end