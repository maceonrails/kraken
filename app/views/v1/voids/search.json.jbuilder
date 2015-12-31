json.order_items @order_items do |item|
  json.order_no 				item.order.table.name
	json.order_created_at item.created_at
	json.product_name 		item.product.name
	json.tenant_name 			item.product.tenant.name
	json.quantity 				item.quantity
	json.void_quantity 		item.void_quantity
	json.void_by 					item.voider_name
	json.void_by_role 		item.voider_role
	json.void_note 				item.void_note

end

json.total @total
