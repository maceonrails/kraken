# == Schema Information
#
# Table name: products
#
#  id                  :uuid             not null, primary key
#  company_id          :uuid
#  product_category_id :uuid
#  name                :string
#  picture             :string
#  active              :boolean          default(TRUE)
#  default_price       :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class Product < ActiveRecord::Base
end
