# == Schema Information
#
# Table name: companies
#
#  id         :uuid             not null, primary key
#  name       :string
#  address    :text
#  join_at    :date
#  expires    :date
#  email      :string
#  phone      :string
#  mobile     :string
#  logo       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Company < ActiveRecord::Base
end
