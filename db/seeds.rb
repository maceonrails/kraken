# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
User.create(username: 'eresto', role: :eresto, password: 'super123', email: 'eresto@eresto.co.id')

(1..100).each do |num|
	table = Table.create(name: num.to_s)
	Table.create(name: num.to_s+'A', parent_id: table.id)
	Table.create(name: num.to_s+'B', parent_id: table.id)
	Table.create(name: num.to_s+'C', parent_id: table.id)
end