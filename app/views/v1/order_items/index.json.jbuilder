json.order_items @order_items do |order_item|
  json.extract! order_item, :id, :quantity, :note, :served, :void, :paid, :paid_amount, :tax_amount, :discount_amount, :split_quantity, :paid_quantity, :printed_quantity
  json.choice order_item.choice
  json.order order_item.order
  json.product_id order_item.product_id
  json.price order_item.product.price - order_item.product.discount.try(:amount).to_i
  json.product do
  	json.choices order_item.product.choices
  end

end

