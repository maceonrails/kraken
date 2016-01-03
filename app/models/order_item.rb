class OrderItem < ActiveRecord::Base
  belongs_to :voider, class_name: 'User', foreign_key: 'void_by'
  belongs_to :oc_giver, class_name: 'User', foreign_key: 'oc_by'
	belongs_to :order
	belongs_to :product
	belongs_to :choice
	belongs_to :discount

  before_save :calculate_amount
  # before_update :check_quantity
  before_create :set_price

  delegate :name, :role, to: :voider, prefix: true, allow_nil: true
  delegate :name, :role, to: :oc_giver, prefix: true, allow_nil: true

  # default_scope { order(updated_at: :desc) }

  def active_quantity
    if paid || quantity.to_i <= void_quantity.to_i + oc_quantity.to_i + paid_quantity.to_i
      res = paid_quantity.to_i + oc_quantity.to_i
    else
      res = unpaid_quantity.to_i
    end
    return res > 0 ? res : 0
  end

  def unpaid_quantity
    quantity.to_i - void_quantity.to_i - oc_quantity.to_i - paid_quantity.to_i
  end

	def self.void_items(user, params)
		orders = []
    params[:orders].each do |order|
      orders << void_item(user, order, params)
    end
    return orders
  end

  def self.oc_items(user, params)
    payment = Payment.new
    params[:orders].each do |order|
      payment.orders << oc_item(user, order, params)
    end
    payment.oc_amount = payment.total
    payment.save!
    return orders
  end

  def self.void_item(user, order_params, params)
    order = Order.find(order_params[:id])
    order_params['order_items'].each do |item|
      if item[:pay_quantity] > 0
        order_item = OrderItem.find(item['id'])
        order_item.update(
          void: true,
          void_by: user.id,
          void_note: params[:note],
          void_quantity: item["pay_quantity"].to_i + order_item.void_quantity
        )
        if order_item.unpaid_quantity <= 0
          order_item.update_attributes(served: true, paid: true)
        end
      end
    end
    clear_complete_order(order)
    return order
  end

  def self.oc_item(user, order_params, params)
    order = Order.find(order_params[:id])
    order_params['order_items'].each do |item|
      order_item = OrderItem.find(item['id'])
      order_item.update(
        oc_by: user.id,
        oc_note: params[:note],
        quantity: item["pay_quantity"].to_i + order_item.oc_quantity
      )
      if order_item.unpaid_quantity <= 0
        order_item.update_attributes(served: true, paid: true)
      end
    end
    clear_complete_order(order)
    return order
  end

  def total_price
    (active_quantity * paid_price)
  end

  def calc_discount_amount
    self.discount_amount = (discount ? discount.amount || discount.percentage.to_f/100 * paid_price : 0) * active_quantity
  end

  def calc_tax_amount
    taxs = order.payment.cashier.outlet.taxs rescue Outlet.first.taxs;
    self.tax_amount = 0;
    taxs.each_pair do |name, amount|
      percentage = amount.to_f / 100
      self.tax_amount += (percentage * ((paid_quantity.to_i + oc_quantity.to_i) * paid_price)).to_i
    end rescue true
  end

  def calc_paid_amount
    self.paid_amount = self.tax_amount + ((paid_quantity.to_i + oc_quantity.to_i) * paid_price) - self.discount_amount
  end

  def paid_price
    price.blank? ? product.price : price
  end

  def calculate_amount
    calc_discount_amount
    calc_tax_amount
    calc_paid_amount
  end

  def self.clear_complete_order(order)
    unless Order.joins(:order_items).where("orders.id = ? AND quantity > (void_quantity + oc_quantity + paid_quantity)", order.id).exists?
      order.update waiting: false
      Table.where(order_id: order.id).update_all(order_id: nil) if order.table
    end
  end

  def check_quantity
    if unpaid_quantity <= 0
      self.served = true
      self.paid = true
    end 
  end

  def set_price
    self.price = product.price
  end
end
