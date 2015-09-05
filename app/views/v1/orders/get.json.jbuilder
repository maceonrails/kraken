json.order do
  json.extract! @order, :id, :name, :servant_id, :table_id
  json.table @order.table
  json.products @order.order_items do |item|
      json.partial! 'v1/products/details', product: item.product
      json.take_away  item.take_away
      json.type       item.take_away == true ? 'Take Away' : 'Dine In'
      json.quantity   item.quantity
      json.choice     item.saved_choice
      json.note       item.note.split(',') rescue ''
      json.void       item.void
      json.void_note  item.void_note
      json.saved      true
  end
end

