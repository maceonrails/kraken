json.rooms @rooms do |room|
  json.extract! room, :id, :name
  json.tables room.tables
end

