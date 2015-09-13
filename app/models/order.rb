class Order < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper

	has_many   :order_items
  belongs_to :discount_provider, foreign_key: :discount_by, class_name: 'User'
  belongs_to :table
  belongs_to :server, class_name: 'User', foreign_key: 'servant_id'

  before_create :set_queue

  def set_queue
    last_order = Order.order(:created_at).where("created_at >= ?", Time.zone.now.beginning_of_day).last
    self.queue_number = (last_order.try(:queue_number) || 0) + 1
  end

  def self.get_waiting_orders
    where("orders.table_id IS NULL AND orders.waiting IS TRUE")
  end

  def get_active_items
    order_items.where("quantity > paid_quantity")
  end

  def self.make_order(params)
    if save_from_servant(params)
      order = self.find(params[:id])
    end
  end
  
  def self.print_order(params)
    order = self.find(params[:id])
    order.do_print(params, preview: true)
  end

  def self.pay_order(params)
    save_from_servant(params)
    order = Order.find(params[:id])
    order.transaction do
      begin
        params[:order_items].each do |item|
          order_item = OrderItem.find_by(order_id: params['id'], product_id: item['product_id'])
          if item['pay_quantity'].zero? || item['pay_quantity'] > item['quantity'] - item['paid_quantity']
            item['pay_quantity'] = item['quantity'] - item['paid_quantity']
          end
          item['paid_quantity'] += item['pay_quantity']
          item['paid_quantity'] = item['quantity'] if item['paid_quantity'] > item['quantity']
          item['paid'] = true
          item['pay_quantity'] = 0
          order_item.update!(item.except(:id, :price))
        end
        unless Order.joins(:order_items).where("orders.id = ? AND quantity > paid_quantity", order.id).exists?
          order.update waiting: false
          # order.table.update order_id: nil if order.table
          Table.where(order_id: order.id).update_all(order_id: nil)
        end
        if params['discount_amount']
          order.update(discount_amount: params['discount_amount'], discount_by: params['discount_by'])
        end
        order.do_print(params, preview: false)
        return true
      rescue Exception => e
        return false
      end
    end
  end

  def self.void_order(order_id, user, params)
    order = find(order_id)
    params['order_items'].each do |item|
      order_item = OrderItem.find(item['id'])
      item["void_by"] = user.id
      item["void_quantity"] = order_item.quantity
      item["void"] = true
      order_item.update(item.except(:id, :price))
    end
    unless Order.joins(:order_items).where("orders.id = ? AND quantity > void_quantity", order.id).exists?
      order.update waiting: false
      order.table.update order_id: nil if order.table
    end
    return true
  end

  def self.void_item(item)
    order_item = OrderItem.find(item['id'])
    order_item.update(item.except(:id, :price))
    unless Order.joins(:order_items).where("orders.id = ? AND quantity > void_quantity", order_item.order_id).exists?
      order.update waiting: false
      order.table.update order_id: nil if order.table
    end
    return true
  end

  def self.save_from_servant(params)
    begin
      if params['id']
        order = Order.find(params['id'])
      else
        order = Order.create
      end

      #save or update order
      order.update name: params['name'], table_id: params['table_id'], servant_id: params['servant_id']

      # update table data with order id
      Table.update(params['table_id'], order_id: order.id) if params['table_id']

      #get taxs
      taxs  = Outlet.first.taxs;

      params['products'] = params[:products] ? params[:products] : params[:order_items]

      # order_item
      params['products'].each do |prd|
        product_id = params[:order_items] ? prd['product_id'] : prd[:id]
        order_item_id = params[:order_items] ? prd[:id] : prd['order_item_id']

        if order_item_id
          orderItem = OrderItem.find(order_item_id)
        else
          orderItem = OrderItem.create
        end

        orderItem.order_id = order.id
        orderItem.product_id = product_id

        discount      = Discount.where(product_id: product_id).last
        discount      = discount.nil? ? 0 : discount.amount.to_i
        dsc_qty       = discount * prd['quantity'].to_i
        prices        = orderItem.product.price.to_i * prd['quantity'].to_i
        prices        = prices - dsc_qty

        # prices = prd['price'].to_i * prd['quantity'].to_i

        tax_component = 0;
        taxs.each_pair do |name, amount|
          percentage = amount.to_f / 100
          tax_component += (percentage * prices).to_i
        end rescue true

        note = prd['note'].respond_to?(:join) ? prd['note'].join(',') : prd['note']
        orderItem.update(
          order_id:         order.id,
          product_id:       product_id,
          quantity:         prd['quantity'],
          note:             note,
          void:             prd['void'],
          paid_amount:      (tax_component + prices),
          tax_amount:       tax_component,
          discount_amount:  dsc_qty,
          void_note:        prd['void_note'],
          take_away:        prd['take_away'],
          saved_choice:     prd['choice'],
          void_by:          prd['void_by'],
          pay_quantity:     prd['pay_quantity'] || 0
        )
      end

      return true
    rescue Exception => e
      return false
    end
  end

  # def self.do_print(params)
  #   self.new.execute_print(params)
  # end

  def do_print(params, opts = { preview: true })
    #params :   pay_amount = cust_pay_amount
              # id = order_id
              # opts[:preview] = 'yes' || 'no'

    outlet = Outlet.first
    order  = Order.includes(:table, :order_items, :server).find(params[:id])

    text = center(true)

    text << outlet.name.to_s + "\n"
    text << outlet.address.gsub!("\n", " ").to_s + "\n"
    text << "Telp:" + outlet.phone.to_s + "/" + outlet.mobile.to_s + "\n"
    text << "\n"
    text << emphasized(true)
    if order.table
      text << "Table : "
      text << order.table.name.to_s + "\n"
    else
      text << "Take Away\n"
    end

    text << Time.now.strftime("%d %B %Y").to_s + "\n"

    text << emphasized(false)
    text << center(false)
    text << "Cust: "
    text << order.name.to_s
    text << 9.chr
    text << right(true)
    text << "Serv: "
    text << (order.server.try(:profile).try(:name) || order.server.try(:email) || outlet.name)
    text << right(false)
    text << "\n"

    text << center(true)
    text << line
    text << center(false)

    #order items
    sub_total      = 0
    discount_total = 0
    params[:order_items].each do |order_item|
      item = OrderItem.find(order_item['id'])
      # print_qty = item.paid_quantity - item.printed_quantity
      print_qty = order_item['pay_quantity']

      if !item.void && item.paid && print_qty > 0
        prd_name = print_qty.to_s + " " + item.product.name.to_s.capitalize
        text << prd_name

        if (prd_name.length > 20)
          text << "\n"
        end

        text << 9.chr
        text << right(true)

        price_qty = print_qty * item.product.price.to_i
        sub_total += price_qty

        text << number_to_currency(price_qty, unit: "Rp ", separator: ",", delimiter: ".", precision: 0)
        text << right(false)
        text << "\n"

        if item.product.discount
          text << "   Discount: " + item.product.discount.name.to_s
          text << 9.chr
          text << right(true)
          disc_pric = item.product.discount.amount.to_i * print_qty
          text << number_to_currency(disc_pric, unit: "Rp ", separator: ",", delimiter: ".", precision: 0)
          text << right(false)
          text << "\n"
          discount_total += disc_pric
        end
      end
    end

    text << center(true)
    text << line
    text << center(false)

    text << "  SUBTOTAL"
    text << 9.chr
    text << right(true)
    text << number_to_currency(sub_total, unit: "Rp ", separator: ",", delimiter: ".", precision: 0)
    text << right(false)
    text << "\n"

    if discount_total > 0

      if order.discount_amount && order.discount_amount.to_i > 0
        discount_total += order.discount_amount.to_i
        text << "  ORDER DISCOUNTS"
        text << 9.chr
        text << right(true)
        text << " - "
        text << number_to_currency(order.discount_amount.to_i, unit: "Rp ", separator: ",", delimiter: ".", precision: 0)
        text << right(false)
        text << "\n"
      end

      if order.discount_percent && order.discount_percent.to_i > 0
        percentage = order.discount_percent.to_f / 100
        ord_dsc    = (percentage * sub_total).to_i

        discount_total += ord_dsc.to_i
        text << "  ORDER DISCOUNTS"
        text << 9.chr
        text << right(true)
        text << " - "
        text << number_to_currency(ord_dsc.to_i, unit: "Rp ", separator: ",", delimiter: ".", precision: 0)
        text << right(false)
        text << "\n"
      end

      text << "  TOTAL DISCOUNTS"
      text << 9.chr
      text << right(true)
      text << " - "
      text << number_to_currency(discount_total, unit: "Rp ", separator: ",", delimiter: ".", precision: 0)
      text << right(false)
      text << "\n"
    end

    taxs = 0;
    if outlet.taxs
      text << center(true)
      text << line
      text << center(false)
    end

    grand_total     = sub_total - discount_total

    outlet.taxs.each_pair do |name, amount|
      percentage    = amount.to_f / 100
      tax_component = (percentage * grand_total.to_i).to_i
      taxs         += tax_component

      text << "  " + name.to_s.capitalize + " " + amount.to_s + "%"
      text << 9.chr
      text << right(true)
      text << number_to_currency(tax_component, unit: "Rp ", separator: ",", delimiter: ".", precision: 0)
      text << right(false)
      text << "\n"
    end

    text << center(true)
    text << line
    text << center(false)

    text << emphasized(true)
    text << "  TOTAL"
    text << 9.chr
    text << right(true)
    grand_total += taxs
    text << number_to_currency(grand_total, unit: "Rp ", separator: ",", delimiter: ".", precision: 0)
    text << right(false)
    text << emphasized(false)
    text << "\n"

    unless opts[:preview]
      text << center(true)
      text << line
      text << center(false)

      text << emphasized(true)
      text << "  PAY"
      text << 9.chr
      text << right(true)
      text << number_to_currency(params[:pay_amount].to_i, unit: "Rp ", separator: ",", delimiter: ".", precision: 0)
      text << right(false)
      text << emphasized(false)
      text << "\n"

      text << emphasized(true)
      text << "  CHANGE"
      text << 9.chr
      text << right(true)
      text << number_to_currency((grand_total - params[:pay_amount].to_i), unit: "Rp ", separator: ",", delimiter: ".", precision: 0)
      text << right(false)
      text << emphasized(false)
      text << "\n"
    end

    text << center(true)
    text << "=================================\n"

    text << "\n"
    text << emphasized(true)
    text << "Thanks For Your Visit\n"
    text << "Till Next Time"
    text << emphasized(false)
    text << center(false)
    text << "\n\n\n\n\n\n\n"

    succeed = true

    if sub_total > 0
      begin
        begin
          printer = Printer.where(default: true).first
          fd = IO.sysopen(printer.printer, 'w+')
          printer = IO.new(fd)
          printer.puts text
          printer.close
        rescue Exception => e
          begin
            printer = Printer.where.not(default: true).first
            fd = IO.sysopen(printer.printer, 'w+')
            printer = IO.new(fd)
            printer.puts text
            printer.close
          rescue Exception => e
            succeed = false
          end
        end
      rescue Exception => e
        succeed = false
      end

      if succeed && !opts[:preview]
        order.order_items.each do |item|
          item.update(printed_quantity: item.paid_quantity)
        end
      end
    end

    return { status: succeed, printed: sub_total > 0}
  end

  def breaks
    return "\n\n"
  end

  def emphasized(on)
    text = 27.chr
    text << 33.chr
    if on
      text << 8.chr
    else
      text << 0.chr
    end
    return text
  end

  def center(on)
    text = 27.chr
    text << 97.chr
    if on
      text << 1.chr
    else
      text << 0.chr
    end
    return text
  end

  def right(on)
    text = 27.chr
    text << 101.chr
    text << 48.chr
    text << 3.chr
    text << 27.chr
    text << 97.chr
    if on
      text << 2.chr
    else
      text << 0.chr
    end
    return text
  end

  def line
    return "---------------------------------\n"
  end
end
