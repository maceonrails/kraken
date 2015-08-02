# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
User.create( role: :eresto, password: 'super123', email: 'eresto@eresto.co.id')
User.create( role: :superadmin, password: 'super123', email: 'admin@bobercafe.com')