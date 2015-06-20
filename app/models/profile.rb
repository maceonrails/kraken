# == Schema Information
#
# Table name: profiles
#
#  id             :uuid             not null, primary key
#  user_id        :integer
#  name           :string
#  address        :text
#  phone          :string
#  join_at        :date
#  contract_until :date
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Profile < ActiveRecord::Base
	belongs_to :user
  # Date.parse('Sat, 20 Oct 2012').strftime('%Y-%m-%d')
end
