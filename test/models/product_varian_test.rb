# == Schema Information
#
# Table name: product_varians
#
#  id            :uuid             not null, primary key
#  product_id    :uuid
#  name          :string
#  picture       :string
#  default_price :string
#  active        :boolean          default(TRUE)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'test_helper'

class ProductVarianTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
