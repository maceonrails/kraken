class Order < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper

	has_many   :order_items
  belongs_to :discount_provider, foreign_key: :discount_by, class_name: 'User'
  belongs_to :table
  belongs_to :server, class_name: 'User', foreign_key: 'servant_id'
  belongs_to :cashier, class_name: 'User', foreign_key: 'cashier_id'

  before_create :set_queue
  before_create :set_struck_id

  scope :waiting_orders, -> { where("orders.table_id IS NULL AND orders.waiting IS TRUE") }
  scope :latest, -> { order(updated_at: :desc) }
  scope :histories, -> { where("orders.waiting IS NOT TRUE").latest }
  scope :search, -> (query) do
    if query
      if query.downcase.include?("table")
        joins(:table).where('tables.name ILIKE :q', q: "%#{query.split(" ").last}%")
      elsif query.downcase.include?("queue")
        where('queue_number::text ILIKE :q', q: "%#{query.split(" ").last}%")
      else
        where('name || struck_id ILIKE :q', q: "%#{query}%")
      end
    end
  end

  def set_queue
    last_order = Order.order(:created_at).where("created_at >= ?", Time.zone.now.beginning_of_day).last
    self.queue_number = (last_order.try(:queue_number) || 0) + 1 if self.table_id.blank?
  end

  def set_struck_id
    holder = '0000'
    orders = Order.where("created_at >= ?", Time.zone.now.beginning_of_day).count + 1
    orders = holder[0..(holder.length - orders.to_s.length)] + orders.to_s
    self.struck_id = 'BT-' + orders + '-' + Time.now.strftime('%d/%m/%Y')
  end

  def get_active_items
    waiting ? order_items.where("quantity > (paid_quantity + void_quantity + oc_quantity)") : order_items
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
    # order.transaction do
    #   begin
        params[:order_items].each do |item|
          order_item = OrderItem.find_by(order_id: params['id'], product_id: item['product_id'])
          if item['pay_quantity'].zero? || item['pay_quantity'] > item['quantity'] - item['paid_quantity'] - order_item.void_quantity - order_item.oc_quantity
            item['pay_quantity'] = item['quantity'] - item['paid_quantity'] - order_item.void_quantity - order_item.oc_quantity
          end
          item['paid_quantity'] += item['pay_quantity']
          item['paid_quantity'] = item['quantity'] if item['paid_quantity'] > item['quantity']
          item['paid'] = true
          item['pay_quantity'] = 0

          order_item.update!(item.except(:id, :price, :print_quantity))

          item['print_quantity'] = item['paid_quantity']
        end
        clear_complete_order(order)
        if params['discount_amount']
          order.update(
            discount_amount: params['discount_amount'],
            discount_percent: params['discount_percent'],
            discount_by: params['discount_by']
          )
        end

        order.do_print(params, preview: false)
        return true
    #   rescue Exception => e
    #     return false
    #   end
    # end
  end

  def self.void_order(order_id, user, params)
    order = find(order_id)
    params['order_items'].each do |item|
      order_item = OrderItem.find(item['id'])
      item["void_by"] = user.id
      item["void_note"] = params['note']
      item["void_quantity"] = item["pay_quantity"] + order_item.void_quantity
      order_item.update(item.except(:id, :price, :pay_quantity, :quantity))
    end
    clear_complete_order(order)
    return true
  end

  def self.oc_order(order_id, user, params)
    order = find(order_id)
    params['order_items'].each do |item|
      order_item = OrderItem.find(item['id'])
      item["oc_by"] = user.id
      item["oc_note"] = params['note']
      item["oc_quantity"] = item["pay_quantity"] + order_item.oc_quantity
      order_item.update(item.except(:id, :price, :pay_quantity, :quantity))
    end
    clear_complete_order(order)
    return true
  end

  def self.void_item(item)
    order_item = OrderItem.find(item['id'])
    order_item.update(item.except(:id, :price))
    clear_complete_order(order_item.order)
    return true
  end

  def self.clear_complete_order(order)
    unless Order.joins(:order_items).where("orders.id = ? AND quantity > (void_quantity + oc_quantity + paid_quantity)", order.id).exists?
      order.update waiting: false
      Table.where(order_id: order.id).update_all(order_id: nil) if order.table
    end
  end

  def self.save_from_servant(params)
    begin
      if params['id']
        order = Order.find(params['id'])
      else
        order = Order.create
      end

      order.name = params['name'] if params['name'].present?
      order.table_id = params['table_id'] if params['table_id'].present?
      order.servant_id = params['servant_id'] if params['servant_id'].present?
      order.cashier_id = params['cashier_id'] if params['cashier_id'].present?
      order.person = params['person'] if params['person'].present?
      order.discount_amount = params['discount_amount'] if params['discount_amount'].present?
      order.discount_percent = params['discount_percent'] if params['discount_percent'].present?

      #save or update order
      order.save!

      # update table data with order id
      Table.update(params['table_id'], order_id: order.id) if params['table_id'].present?

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
        product = Product.find_by_id(product_id)

        discount      = product.discounts.find_by_id(prd['discount_id'])
        discount      = discount.nil? ? 0 : discount.amount.to_i
        dsc_qty       = discount * prd['quantity'].to_i
        prices        = product.price.to_i * prd['quantity'].to_i
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
          discount_id:      prd['discount_id'],
          discount_amount:  dsc_qty,
          void_note:        prd['void_note'],
          take_away:        prd['take_away'],
          saved_choice:     prd['choice'] || prd['saved_choice'],
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
    params = recursive_symbolize_keys params
    outlet = Outlet.first
    order  = Order.includes(:table, :order_items, :server).find(params[:id])

    text = center(true)
    text << outlet.name.to_s + "\n"
    text << outlet.address.to_s.gsub!("\n", " ").to_s + "\n"
    text << "Telp: 0" + outlet.phone.to_s
    if outlet.mobile
      text << "/" + outlet.mobile.to_s + "\n"
    else
      text << "\n"
    end

    unless order.waiting
      text << center(false)
      text << "\nREPRINT \n"
      text << center(true)
    end

    text << "\n"
    text << emphasized(true)
    if order.table
      text << "Table : "
      text << order.table.name.to_s + "\n"
    else
      text << "Take Away\n"
    end

    text << Time.now.strftime("%d %B %Y %H:%M").to_s + "\n"

    text << emphasized(false)
    text << center(false)
    text << "Receipt ID  : "
    text << order.struck_id.to_s
    text << "\n"
    text << "Customer    : "
    text << order.name.to_s
    text << " / "
    text << order.person.to_i.to_s
    text << "\n"
    text << "Serv/Cashier: "
    text << (order.server.try(:profile).try(:name) || order.server.try(:email) || outlet.name)
    text << " / "
    text << (order.cashier.try(:profile).try(:name) || order.cashier.try(:email) || outlet.name)
    text << "\n"

    text << center(true)
    text << line
    text << center(false)

    #order items
    sub_total      = 0
    discount_total = 0
    params[:order_items].each do |order_item|
      item = OrderItem.find_by_product_id(order_item[:product_id])
      # print_qty = item.paid_quantity - item.printed_quantity
      print_qty = order_item[:print_quantity]

      if !item.void && print_qty > 0
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
        item.discount = Discount.where(id: order_item[:discount_id]).first
        if item.discount
          text << "   Discount: " + item.discount.name.to_s
          text << 9.chr
          text << right(true)
          if item.discount.percentage.to_i > 0
            discount_holder = item.product.price.to_i * item.discount.percentage.to_i / 100
          else
            discount_holder = item.discount.amount
          end

          disc_pric = discount_holder.to_i * print_qty
          text << number_to_currency(disc_pric, unit: "Rp ", separator: ",", delimiter: ".", precision: 0)
          text << right(false)
          text << "\n"
          discount_total += disc_pric
        end
      end
    end

    if params[:discount_amount] && params[:discount_amount].to_i > 0
      discount_total += params[:discount_amount].to_i
      text << "  ORDER DISCOUNTS"
      if (params[:discount_percent].to_i > 0)
        text << " #{params[:discount_percent].to_i}%"
      end
      text << 9.chr
      text << right(true)
      text << " - "
      text << number_to_currency(params[:discount_amount].to_i, unit: "Rp ", separator: ",", delimiter: ".", precision: 0)
      text << right(false)
      text << "\n"
    end

    text << center(true)
    text << line
    text << center(false)

    text << "  TOTAL"
    text << 9.chr
    text << right(true)
    text << number_to_currency(sub_total, unit: "Rp ", separator: ",", delimiter: ".", precision: 0)
    text << right(false)
    text << "\n"

    if discount_total > 0
      text << "  TOTAL DISCOUNTS"
      text << 9.chr
      text << right(true)
      text << " - "
      text << number_to_currency(discount_total, unit: "Rp ", separator: ",", delimiter: ".", precision: 0)
      text << right(false)
      text << "\n"

      text << center(true)
      text << line
      text << center(false)

      text << ""
      text << 9.chr
      text << right(true)
      text << number_to_currency((sub_total - discount_total), unit: "Rp ", separator: ",", delimiter: ".", precision: 0)
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
    text << "  GRAND TOTAL"
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
      text << number_to_currency(params[:cash_amount].to_i, unit: "Rp ", separator: ",", delimiter: ".", precision: 0)
      text << right(false)
      text << emphasized(false)
      text << "\n"

      text << emphasized(true)
      text << "  CHANGE"
      text << 9.chr
      text << right(true)
      text << number_to_currency((params[:cash_amount].to_i - grand_total), unit: "Rp ", separator: ",", delimiter: ".", precision: 0)
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
    puts "==================="
    puts "start printing "
    puts "\n"
    puts text.to_s

    if sub_total > 0
      begin
        printer = Printer.where(default: true).first
        puts printer.inspect
        puts "========================"
        fd = IO.sysopen(printer.printer, 'w+')
        printer = IO.new(fd)
        printer.puts text
        printer.close
      rescue Exception => e
        puts '======================'
        puts e.inspect
        puts '=================='
        begin
          printer = Printer.where.not(default: true).first
          fd = IO.sysopen(printer.printer, 'w+')
          printer = IO.new(fd)
          printer.puts text
          printer.close
        rescue Exception => e
          puts '====================='
          puts e.inspect
          puts '====================='
          succeed = false
        end
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

  def recursive_symbolize_keys(h)
    case h
    when Hash
      Hash[
        h.map do |k, v|
          [ k.respond_to?(:to_sym) ? k.to_sym : k, recursive_symbolize_keys(v) ]
        end
      ]
    when Enumerable
      h.map { |v| recursive_symbolize_keys(v) }
    else
      h
    end
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
