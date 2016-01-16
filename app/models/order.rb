class Order < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper

	has_many   :order_items
  belongs_to :discount_provider, foreign_key: :discount_by, class_name: 'User'
  belongs_to :table
  belongs_to :payment
  belongs_to :server, class_name: 'User', foreign_key: 'servant_id'
  belongs_to :cashier, class_name: 'User', foreign_key: 'cashier_id'

  # before_create :set_queue
  # before_create :set_struck_id
  # after_create :set_queue_number
  belongs_to :outlet
  before_create :set_outlet_id
  
  def set_outlet_id
    if self.outlet_id.blank?
      self.outlet = Outlet.first
    end
  end

  # default_scope { order(updated_at: :desc) }
  scope :waiting_orders, -> { where("orders.table_id IS NULL AND orders.waiting IS TRUE") }
  scope :latest, -> { order(updated_at: :desc) }
  scope :histories, -> { where("orders.payment_id IS NOT NULL").latest }
  scope :search, -> (query) do
    if query.present?
      if query.downcase.include?("table") || query.downcase.include?("order")
        joins(:table).where('tables.name ILIKE :q', q: "%#{query.split(" ").last}%")
      elsif query.downcase.include?("queue")
        where('queue_number::text ILIKE :q', q: "%#{query.split(" ").last}%")
      else
        joins(:payment)
          .where('payments.receipt_number ILIKE :q OR orders.name ILIKE :q', q: "%#{query}%")
      end
    end
  end

  def set_queue
    last_order = Order.order(:created_at).where("created_at >= ?", Time.zone.now.beginning_of_day).last
    self.queue_number = (last_order.try(:queue_number) || 0) + 1 if self.table_id.blank?
  end

  def set_queue_number
    self.queue_number = self.table.name.to_i
  end

  def set_struck_id
    holder = '0000'
    orders = Order.where("created_at >= ?", Time.zone.now.beginning_of_day).count + 1
    orders = holder[0..(holder.length - orders.to_s.length)] + orders.to_s
    self.struck_id = 'BT-' + orders + '-' + Time.now.strftime('%d/%m/%Y')
  end

  def get_active_items
    waiting ? order_items.where("quantity::int > (paid_quantity::int + void_quantity::int + oc_quantity::int)") : order_items
  end

  def self.make_order(params)
    if save_from_servant(params)
      order = self.find(params[:id])
    end
  end

  def self.print_order(params)
    order = self.find(params[:id])
    Printer.print_order(params, preview: true)
  end

  def self.clear_complete_order(order)
    unless Order.joins(:order_items).where("orders.id = ? AND quantity > (void_quantity + oc_quantity + paid_quantity)", order.id).exists?
      order.update waiting: false
      Table.where(order_id: order.id).update_all(order_id: nil) if order.table
    end
  end

  def self.save_from_cashier(params)
    
  end

  def self.save_from_servant(params, from_cashier = false)
    params['products'] = params[:products] ? params[:products] : params[:order_items]
    return false if params['products'].blank? 
    # begin
      if params['id'].blank? || params['type'] == 'move'
        order = Order.where("payment_id IS NULL AND waiting IS TRUE")
                     .where(table_id: params['table_id'], created_at: 8.hour.ago..Time.now)
                     .first
        if order.blank?
          order = Order.create
        end
      else
        order = Order.find(params['id'])
        return false if order.blank? || order.payment_id.present? || order.waiting == false || (order.locked && !from_cashier) 
      end

      order.name = params['name'] if params['name'].present?
      order.table_id = params['table_id'] if params['table_id'].present?
      order.servant_id = params['servant_id'] if params['servant_id'].present?
      order.cashier_id = params['cashier_id'] if params['cashier_id'].present?
      order.person = params['person'].present? ? params['person'] : 1

      if params['type'] == 'move'
        order.name = "split from " + order.name
        order.person = 0
      end

      #save or update order
      order.save!

      # update table data with order id
      Table.update(params['table_id'], order_id: order.id) if params['table_id'].present? && params["type"] != 'move'

      # order_item
      params['products'].each do |prd|
        product_id = params[:order_items] ? prd['product_id'] : prd[:id]
        order_item_id = params[:order_items] ? prd[:id] : prd['order_item_id']

        if order_item_id.blank? || params['type'] == 'move'
          orderItem = order.order_items.create(product_id: product_id)
        else
          orderItem = order.order_items.find(order_item_id)
        end
        note = prd['note'].respond_to?(:join) ? prd['note'].join(',') : prd['note']

        prd['void_by'] = orderItem.product.try(:tenant_id) if prd['void_by'].blank? && prd['void_quantity'].to_i > 0

        orderItem.update(
          quantity:         prd['quantity'] || orderItem.quantity,
          note:             note || orderItem.note,
          void:             prd['void'] || orderItem.void,
          discount_id:      prd['discount_id'] || orderItem.discount_id,
          void_note:        prd['void_note'] || orderItem.void_note,
          take_away:        prd['take_away'] || orderItem.take_away,
          saved_choice:     prd['choice'] || prd['saved_choice'],
          void_by:          prd['void_by'] || orderItem.void_by,
          void_quantity:    prd['void_quantity'] || orderItem.void_quantity,
          pay_quantity:     prd['pay_quantity'] || 0
        )
      end

      clear_complete_order(order)

      return order
    # rescue Exception => e
    #   return false
    # end
  end

  
end
