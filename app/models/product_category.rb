# == Schema Information
#
# Table name: product_categories
#
#  id         :uuid             not null, primary key
#  company_id :uuid
#  name       :string
#  valid      :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ProductCategory < ActiveRecord::Base
	has_many :product_sub_categories
end
