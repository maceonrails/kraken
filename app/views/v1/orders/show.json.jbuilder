json.id 							@order.id
json.name 						@order.name
json.waiting 					@order.waiting
json.queue_number 		@order.queue_number
json.table_id 				@order.table_id
json.servant_id 			@order.servant_id
json.struck_id 				@order.struck_id
json.discount_amount 	@order.discount_amount
json.discount_percent @order.discount_percent
json.cash_amount 			@order.cash_amount
json.debit_amount 		@order.debit_amount
json.credit_amount 		@order.credit_amount

json.table_name 			@order.table.try(:name)
json.table_location 	@order.table.try(:location)
json.order_items 			@order.get_active_items do |item|
	json.merge! 				item.attributes
	json.price 					item.product.price - item.discount.try(:amount).to_i rescue 0
	json.default_price 	item.product.price
	json.name 					item.product.name
	json.discount 			item.discount
	json.product do
		json.choices item.product.choices
		json.discounts item.product.discounts
	end
end