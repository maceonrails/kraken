# == Schema Information
#
# Table name: inventory_outlets
#
#  id           :integer          not null, primary key
#  outlet_id    :uuid
#  inventory_id :uuid
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class InventoryOutlet < ActiveRecord::Base
end
