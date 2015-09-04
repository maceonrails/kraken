json.extract! @order, :id, :name, :waiting, :queue_number, :table_id
json.orderItems @order.order_items