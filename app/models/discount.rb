class Discount < ActiveRecord::Base
  include Total
  has_many :product_discounts
  has_many :products, through: :product_discounts

  scope :active_by_date, -> { where("?::date BETWEEN start_date::date AND end_date::date", Date.today) }
  scope :active_by_time, -> { where("?::time BETWEEN start_time::time AND end_time::time", Time.now) }
  scope :active_by_days, -> { where("? = ANY (days)", Date.today.strftime("%A")) }
  scope :active, -> { active_by_date.active_by_time.active_by_days }

  def self.create_discount opts = {}
    opts[:name] ||= "Discount #{Time.now.to_date}"
    opts[:start_date] ||= Time.now
    opts[:end_date] ||= 1.week.from_now
    opts[:amount] ||= 0
    opts[:products] ||= []
    create! opts
  end

  def is_active
    if self.start_date && self.end_date
      self.start_date.to_date <= Date.today && self.end_date.to_date >= Date.today
    else 
      true
    end	
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
      discount[:start_date] = discount[:start_date].to_datetime
      discount[:end_date]   = discount[:end_date].to_datetime.end_of_day
      val = discount.values.map { |s| "'#{s}'" }
      val.pop
      val = val.join(',')
      values << "( #{val} )"
    end

    sql = "INSERT INTO discounts (#{keys} ) VALUES #{values.join(", ")}"
    self.connection.execute sql
  end
end
