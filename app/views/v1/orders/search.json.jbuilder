json.orders @orders do |order|
  if params[:from_manager] || params[:history] || order.order_items.joins(:product).where("products.tenant_id = ? AND order_items.served IS NOT TRUE", params[:tenant_id]).count > 0 
    json.extract! order, :id, :name, :person, :created_at, :table_id, :queue_number, :created, :pantry_created, :payment_id
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
        json.time            item.created_at.strftime("%H:%M")
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
