class ProductChoice < ActiveRecord::Base
	belongs_to :product
	belongs_to :choice
end
