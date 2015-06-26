# == Schema Information
#
# Table name: tables
#
#  id         :uuid             not null, primary key
#  name       :string
#  location   :string
#  splited    :boolean          default(FALSE)
#  order_id   :uuid
#  parent_id  :uuid
#  status     :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Table < ActiveRecord::Base
  include Total
  default_scope { where(parent_id: nil) }
  has_many :parts, foreign_key: 'parent_id', class_name: 'TableParts'
end
