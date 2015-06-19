# == Schema Information
#
# Table name: tables
#
#  id         :uuid             not null, primary key
#  name       :string
#  floor      :integer
#  splited    :boolean
#  order_id   :uuid
#  status     :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class TableTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
