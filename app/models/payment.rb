class Payment < ActiveRecord::Base
  has_many :orders
	has_many :order_items, through: :orders
	belongs_to :discount_provider, foreign_key: :discount_by, class_name: 'User'
	belongs_to :cashier, class_name: 'User', foreign_key: 'cashier_id'

	before_create :set_receipt_number
  before_save :set_all_amount

  # default_scope { order(updated_at: :desc) }

  scope :recap, ->(user, start_date = nil, end_date = nil) { 
    between_date(start_date || Date.today.beginning_of_day, end_date || Date.today.end_of_day).where(cashier_id: user.id) 
  }

  scope :between_date, -> (start, finish){ where("payments.created_at >= ? AND payments.created_at <= ?", start, finish) }
  scope :total_cash, -> { sum('total::float - (debit_amount::float + credit_amount::float)') }
  scope :total_debit, -> { sum('debit_amount::float') }
  scope :total_credit, -> { sum('credit_amount::float') }
  scope :total_non_cash, -> { sum('debit_amount::float + credit_amount::float') }
  scope :total_transaction, -> { sum('total').to_f }
  scope :total_sales, -> { joins(orders: {order_items: :product}).sum('total::float') }
  scope :total_product_discount, -> { joins(orders: :order_items).sum('order_items.discount_amount::float') }
  scope :total_order_discount, -> { sum('discount_amount::float') }
  scope :total_taxes, -> { joins(orders: :order_items).sum('order_items.tax_amount') }
  scope :total_per_category, -> { 
      joins(orders: {order_items: {product: {product_sub_category: :product_category}}})
      .select("product_categories.name as name, sum(order_items.paid_quantity) as quantity, sum(order_items.paid_amount) as amount")
      .group("product_categories.id")
      .to_a
  }
  scope :total_receipt, -> { sum('cash_amount - return_amount') }
  scope :average_per_receipt, -> { sum('cash_amount - return_amount') }
  scope :total_pax, -> { joins(:orders).sum('orders.person') }
  scope :average_per_pax, -> { sum('cash_amount - return_amount') }

  Outlet.first.taxs.each do |tax, amount|
    scope "total_#{tax}".to_sym, -> { amount.to_f/100 * total_sales }
  end

  def self.getRecap(user)
    res = recap(user)
    result = {}
    result[:name] = user.try(:name) || user.try(:email)
    result[:date] = start_login.strftime("%d %B %Y").to_s rescue Date.today.strftime("%d %B %Y").to_s

    user.outlet.taxs.each do |tax, amount|
      result[tax] = res.send("total_#{tax}").to_f
    end

    result[:total_product_discount] = res.total_product_discount
    result[:total_order_discount] = res.total_order_discount

    result[:total_cash] = res.total_cash
    result[:total_debit] = res.total_debit
    result[:total_credit] = res.total_credit
    result[:total_non_cash] = res.total_non_cash

    # result[:category] = {}
    # res.total_per_category.each do |cat|
    #   result[:category][cat.name][:amount] = cat.amount
    #   result[:category][cat.name][:quantity] = cat.quantity
    # end

    result[:total_receipt] = res.count
    result[:average_per_receipt] = (res.total_transaction.to_i / res.count rescue 0)
    result[:total_pax] = res.total_pax
    result[:average_per_pax] = (res.total_transaction.to_i / res.total_pax rescue 0)
    result[:total_sales] = res.total_sales
    result[:total_transaction] = res.total_transaction

    return result
  end

  def set_all_amount
    self[:sub_total] = sub_total
    self[:total] = total
    self[:pay_amount] = pay_amount
  end

	def set_receipt_number
    holder = '0000'
    payments = Payment.where("created_at >= ?", Time.zone.now.beginning_of_day).count + 1
    payments = holder[0..(holder.length - payments.to_s.length)] + payments.to_s
    self.receipt_number = 'SA-' + payments + '-' + Time.now.strftime('%d/%m/%Y')
  end

  def sub_total
    result = 0
    self.orders.each do |order|
      order.order_items.each do |item|
        result += item.total_price
      end
    end
    result
  end

  def total
    sub_total + (sub_total * (taxs.values.map(&:to_f).sum/100)) - discount_amount.to_f - discount_products.to_f
  end

  def discount_products
    result = 0
    self.orders.each do |order|
      order.order_items.each do |item|
        result += item.calc_discount_amount
      end
    end
    result
  end

  def taxs
    self.cashier.outlet.taxs rescue {}
  end

  def pay_amount
    self.cash_amount.to_f + self.debit_amount.to_f + self.credit_amount.to_f
  end

  def return_amount
    pay_amount - total
  end

  def self.pay(params)
	  payment = Payment.new
  	payment.transaction do
	  	params[:orders].each do |order|
        order = pay_order(order)
        order.update(cashier_id: params['cashier_id']) if params['cashier_id'].present?
	  		payment.orders << order
	  	end
      payment.cashier_id = params['cashier_id'] if params['cashier_id'].present?
      payment.discount_amount = params['discount_amount'] if params['discount_amount'].present?
      payment.discount_percent = params['discount_percent'] if params['discount_percent'].present?
      payment.discount_by = params['discount_by'] if params['discount_by'].present?
      payment.debit_amount = params['debit_amount'] if params['debit_amount'].present?
      payment.credit_amount = params['credit_amount'] if params['credit_amount'].present?
      payment.cash_amount = params['cash_amount'] if params['cash_amount'].present?
      payment.debit_name = params['debit_name'] if params['debit_name'].present?
      payment.debit_number = params['debit_number'] if params['debit_number'].present?
      payment.credit_name = params['credit_name'] if params['credit_name'].present?
      payment.credit_number = params['credit_number'] if params['credit_number'].present?
  		
      if payment.save
        if params['print'] == 'paper'
          Printer.print_receipt(payment) 
        elsif params['print'] == 'email'
          ReceiptMailer.send_receipt(payment, params[:email]).deliver_later
        end
        return true
      else
        return false
      end
  	end
  end

  def self.pay_order(params)
    order = Order.save_from_servant(params)
    base_order = Order.find(params[:id])
    return false unless order
    params[:order_items].each do |item|
      order_item = order.order_items.find_by(product_id: item['product_id'])
      if params[:type] == 'move'
        base_item = base_order.order_items.find_by(product_id: item['product_id'])
        item['quantity'] = item['pay_quantity']
        item['paid_quantity'] = item['pay_quantity']
        item['void_quantity'] = 0
        item['oc_quantity'] = 0
        base_item.quantity -= item['pay_quantity']
        if base_item.quantity <= 0
          base_item.destroy
        else
          base_item.save
        end
      else
        active_quantity = item['quantity'] - item['paid_quantity'] - order_item.void_quantity - order_item.oc_quantity
      
        if item['pay_quantity'].zero? || item['pay_quantity'] > active_quantity
          item['pay_quantity'] = active_quantity
        end
        item['paid_quantity'] += item['pay_quantity']
        item['paid_quantity'] = item['quantity'] if item['paid_quantity'] > item['quantity']
      end

      item['pay_quantity'] = 0

      active_quantity = item['quantity'] - item['paid_quantity'] - order_item.void_quantity - order_item.oc_quantity
      
      if active_quantity <= 0
        item['paid'] = true 
        item['served'] = true
      end

      order_item.update!(item.except(:id, :price, :print_quantity, :discount))
      item['print_quantity'] = order_item.paid_quantity
    end
    clear_complete_order(order)

    return order
  end

  def self.clear_complete_order(order)
    unless Order.joins(:order_items).where("orders.id = ? AND quantity > (void_quantity + oc_quantity + paid_quantity)", order.id).exists?
      order.update waiting: false
      Table.where(order_id: order.id).update_all(order_id: nil) if order.table
    end
  end
end
