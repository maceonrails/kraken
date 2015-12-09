json.payment do
	json.merge! @payment.attributes
	json.orders @payment.orders do |order|
		json.id 							order.id
		json.name 						order.name
		json.waiting 					order.waiting
		json.queue_number 		order.queue_number
		json.table_id 				order.table_id
		json.servant_id 			order.servant_id
		json.table_name 			order.table.try(:name)
		json.table_location 	order.table.try(:location)
		json.order_items 			order.order_items do |item|
			json.merge! 				item.attributes
			json.price 					item.product.price - item.discount_amount
			json.default_price 	item.product.price
			json.name 					item.product.name
			json.discount 			item.discount
			json.product do
				json.choices item.product.choices
				json.discounts item.product.discounts
				json.price item.product.price
			end
		end
	end
end