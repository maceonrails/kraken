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
  belongs_to :outlet
  has_many :orders

  def self.create_data(params)
    _start   = params[:table][:start].to_i
    _end     = params[:table][:end].to_i
    location = params[:table][:location]
    outlet_id = params[:outlet_id] || Outlet.first.id

    _start.upto(_end) do |n|
      parent = self.create({ location: location, name: n.to_s, outlet_id: outlet_id })
      self.create({location: location, name: n.to_s+'A', parent_id: parent.id, outlet_id: outlet_id})
      self.create({location: location, name: n.to_s+'B', parent_id: parent.id, outlet_id: outlet_id})
      self.create({location: location, name: n.to_s+'C', parent_id: parent.id, outlet_id: outlet_id})
    end
  end

  def self.update_data(params)
    _start   = params[:table][:start].to_i
    _end     = params[:table][:end].to_i
    location = params[:table][:location]

    self.where(location: location).delete_all

    if _start != 0 && _end != 0
      _start.upto(_end) do |n|
        parent = self.create({ location: location, name: n.to_s })
        self.create({location: location, name: n.to_s+'A', parent_id: parent.id})
        self.create({location: location, name: n.to_s+'B', parent_id: parent.id})
        self.create({location: location, name: n.to_s+'C', parent_id: parent.id})
      end
    end
  end
end
