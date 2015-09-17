class Discount < ActiveRecord::Base
  include Total
  belongs_to :product

  scope :active, -> { where("start_date <= ? AND end_date >= ?", Time.now, Time.now) }

  def self.sync(discounts)
    self.unscoped.delete_all
    discounts.each do |discount|
      discount.delete(:id)
      discount.delete(:outlets)
    end
    keys     = discounts.first.keys.join(',')
    values   = []

    discounts.each do |discount|
        values << "( #{discount.values.map { |s| "'#{s}'" }.join(', ')} )"
    end

    sql = "INSERT INTO discounts (#{keys} ) VALUES #{values.join(", ")}"
    self.connection.execute sql
  end
end
