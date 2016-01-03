json.resume @resume
json.payments @payments do |payment|
  json.extract! payment, :receipt_number, :cashier_id, :created_at, :debit_amount, :credit_amount, :discount_amount, :oc_amount, :discount_percent, :discount_by, :note
  json.cash_amount payment[:total].to_f - (payment.debit_amount.to_f + payment.credit_amount.to_f)
  json.total payment[:total].to_f
  json.order_ids payment.orders.joins(:table).pluck('tables.name').join(", ")


  json.cashier do
    json.name payment.cashier.profile.name rescue ''
    json.email payment.cashier.email rescue ''
  end

  json.orders payment.orders do |order|
    json.extract! order, :id, :name, :person, :created_at, :table_id, :queue_number, :created, :pantry_created
    json.table do
    json.name order.table.name
  end if order.table
    json.products order.order_items do |item|
    if !params[:tenant_id] || item.product.tenant_id == params[:tenant_id]
      json.partial! 'v1/products/details', product: item.product
      json.take_away       item.take_away
      json.served          item.served
      json.type            item.take_away == true ? 'Take Away' : 'Dine In'
      json.quantity        item.quantity
      json.choice          item.saved_choice
      json.note            item.note
      json.void            item.void
      json.void_note       item.void_note
      json.paid_amount     item.paid_amount
      json.tax_amount      item.tax_amount
      json.discount_amount item.discount_amount
      json.paid_quantity   item.paid_quantity
      json.void_quantity   item.void_quantity
      json.oc_quantity     item.oc_quantity
      json.void_by do
        item.voider ||= User.new
        item.voider.profile ||= Profile.new
        json.name item.voider.profile.name
        json.email item.voider.email
      end
      json.order_item_id  item.id
    end
  end
  end
end

json.total @total
