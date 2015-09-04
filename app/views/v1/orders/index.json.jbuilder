json.orders @orders do |order|
  json.extract! order, :id, :name, :waiting, :table_id, :queue_number
end

