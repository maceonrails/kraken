# == Schema Information
#
# Table name: inventories
#
#  id         :uuid             not null, primary key
#  company_id :uuid
#  name       :string
#  unit       :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class InventoryTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
