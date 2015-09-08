class OrderItem < ActiveRecord::Base
  belongs_to :voider, class_name: 'User', foreign_key: 'void_by'
	belongs_to :order
	belongs_to :product
	belongs_to :choice
end
