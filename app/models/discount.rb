class Discount < ActiveRecord::Base
  include Total
  belongs_to :product

  scope :active, -> { where("DATE(start_date) <= ? AND DATE(end_date) >= ?", Date.today, Date.today) }

  def is_active
    self.start_date.to_date <= Date.today && self.end_date.to_date >= Date.today
  end

  def self.sync(discounts)
    self.unscoped.delete_all
    discounts.each do |discount|
      discount.delete(:id)
      discount.delete(:outlets)
    end
    keys   = discounts.first.keys
    keys.delete('product')
    keys   = keys.join(',')
    values = []

    discounts.each do |discount|
      val = discount.values.map { |s| "'#{s}'" }
      val.pop
      val = val.join(',')
      values << "( #{val} )"
    end

    sql = "INSERT INTO discounts (#{keys} ) VALUES #{values.join(", ")}"
    self.connection.execute sql
  end
end
