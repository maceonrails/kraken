json.orders @orders do |order|
  json.extract! order, :id, :name, :person, :created_at, :table_id, :queue_number
  json.servant do
    json.name order.server.profile.name rescue ''
    json.email order.server.email rescue ''
  end

  json.cashier do
    json.name order.cashier.profile.name rescue ''
    json.email order.cashier.email rescue ''
  end

  json.table do
    json.name order.table.name
  end if order.table

  json.products order.order_items do |item|
    json.partial! 'v1/products/details', product: item.product
    json.take_away      item.take_away
    json.served         item.served
    json.type           item.take_away == true ? 'Take Away' : 'Dine In'
    json.quantity       item.quantity
    json.choice         item.saved_choice
    json.note           item.note
    json.void           item.void
    json.void_note      item.void_note
    json.paid_amount    item.paid_amount
    json.tax_amount     item.tax_amount
    json.discount_amount item.discount_amount
    json.void_by do
      item.voider ||= User.new
      item.voider.profile ||= Profile.new
      json.name item.voider.profile.name
      json.email item.voider.email
    end
    json.order_item_id  item.id
  end
end

json.total @total
