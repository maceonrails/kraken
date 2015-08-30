json.tables @tables do |table|
  json.id    	table.id
  json.name  	table.name
  json.splited 	table.splited
  json.status   table.status
  json.order_id table.order_id

  json.parts table.parts, :id, :name, :status, :order_id
end

if @total
  json.total @total
else
  json.total @tables.first.total if @tables.first
end