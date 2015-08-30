class ProductSubCategory < ActiveRecord::Base
	has_many :products
	belongs_to :product_category
end
