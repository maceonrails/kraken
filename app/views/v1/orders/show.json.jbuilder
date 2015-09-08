json.extract! @order, :id, :name, :waiting, :queue_number, :table_id
json.order_items @order.order_items