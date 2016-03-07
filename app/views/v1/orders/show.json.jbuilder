json.orders @orders do |order|
	json.id 							order.id
	json.name 						order.name
	json.waiting 					order.waiting
	json.queue_number 		order.queue_number
	json.table_id 				order.table_id
	json.servant_id 			order.servant_id
	json.struck_id 				order.struck_id
	json.discount_amount 	order.discount_amount
	json.discount_percent order.discount_percent

	json.table_name 			order.table.try(:name)
	json.table_location 	order.table.try(:location)
	json.order_items 			order.get_active_items do |item|
		json.merge! 				item.attributes
		json.price 					item.product.price - item.discount_amount
		json.default_price 	item.product.price
		json.name 					item.product.name
		json.discount 			item.discount
		json.time						item.created_at.strftime("%H:%M")
		
		json.product do
			json.choices item.product.choices
			json.discounts item.product.discounts.active
			json.price item.product.price
		end
	end
end