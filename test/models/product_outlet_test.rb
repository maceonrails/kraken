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

require 'test_helper'

class ProductOutletTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
