# == Schema Information
#
# Table name: profiles
#
#  id             :uuid             not null, primary key
#  user_id        :uuid
#  name           :string
#  address        :text
#  phone          :string
#  join_at        :date
#  contract_until :date
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

require 'test_helper'

class ProfileTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
