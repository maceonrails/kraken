class Payment < ActiveRecord::Base
	has_many :orders
	belongs_to :discount_provider, foreign_key: :discount_by, class_name: 'User'
	belongs_to :cashier, class_name: 'User', foreign_key: 'cashier_id'

	before_create :set_receipt_number
  before_save :set_sub_total, :set_total, :set_pay_amount

	def set_receipt_number
    holder = '0000'
    payments = Payment.where("created_at >= ?", Time.zone.now.beginning_of_day).count + 1
    payments = holder[0..(holder.length - payments.to_s.length)] + payments.to_s
    self.receipt_number = 'SA-' + payments + '-' + Time.now.strftime('%d/%m/%Y')
  end

  def set_sub_total
    result = 0
    self.orders.each do |order|
      order.order_items.each do |item|
        result += item.total_price
      end
    end
    self.sub_total = result
  end

  def set_total
    self.total = self.sub_total + (self.sub_total * (taxs.values.map(&:to_f).sum/100)) - self.discount_amount.to_f
  end

  def taxs
    self.cashier.outlet.taxs rescue {}
  end

  def set_pay_amount
    self.pay_amount = self.cash_amount.to_f + self.debit_amount.to_f + self.credit_amount.to_f
  end

  def return_amount
    pay_amount - total
  end

  def self.pay(params)
	  payment = Payment.new
  	payment.transaction do
	  	params[:orders].each do |order|
	  		payment.orders << pay_order(order)
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
  		Printer.print_receipt(payment) if payment.save
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

      item['paid'] = true
      item['pay_quantity'] = 0

      order_item.update!(item.except(:id, :price, :print_quantity))

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
