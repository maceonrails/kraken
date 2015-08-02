# == Schema Information
#
# Table name: outlets
#
#  id         :uuid             not null, primary key
#  name       :string
#  address    :text
#  company_id :uuid
#  email      :string
#  phone      :string
#  mobile     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Outlet < ActiveRecord::Base
  include Total
end
