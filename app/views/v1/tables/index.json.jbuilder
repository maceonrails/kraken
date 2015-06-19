json.token @token

json.tables @tables do |table|
  json.id    	table.id
  json.name  	table.name
  json.splited 	table.splited
  json.location table.location
  json.status   table.status
  json.order_id table.order_id

  json.parts table.parts, :id, :name, :status, :order_id
end

json.total @tables.first.total