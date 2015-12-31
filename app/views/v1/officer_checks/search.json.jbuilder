json.order_items @order_items do |item|
  json.order_no 				item.order.table.name
	json.order_created_at item.created_at
	json.product_name 		item.product.name
	json.tenant_name 			item.product.tenant.name
	json.quantity 				item.quantity
	json.oc_quantity 			item.oc_quantity
	json.oc_by 						item.oc_giver_name
	json.oc_by_role 			item.oc_giver_role
	json.oc_note 					item.oc_note

end

json.total @total
