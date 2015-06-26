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

class TableParts < ActiveRecord::Base
  self.table_name = 'tables'
end
