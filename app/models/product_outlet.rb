# == Schema Information
#
# Table name: product_outlets
#
#  id         :integer          not null, primary key
#  outlet_id  :uuid
#  product_id :uuid
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ProductOutlet < ActiveRecord::Base
end
