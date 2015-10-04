class ProductDiscount < ActiveRecord::Base
  belongs_to :discount
  belongs_to :product
end
