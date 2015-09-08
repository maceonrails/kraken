class Order < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
	has_many   :order_items
  belongs_to :discount_provider, foreign_key: :discount_by, class_name: 'User'
  belongs_to :table
  belongs_to :server, class_name: 'User', foreign_key: 'servant_id'

  def self.pay_order(params)
    unless order = Order.find_by_id(params[:id])
      order = make_order(params)
    end

    order_items = order.get_active_items

    order.transaction do 
      begin
        binding.pry
        order_items.each do |item|
          item.paid_quantity = if item.pay_quantity.zero?
            item.quantity - item.paid_quantity
          else
            item.paid_quantity + item.pay_quantity
          end
          
          item.paid = true
          item.pay_quantity = 0

          unless item.save!
            raise ActiveRecord::Rollback
          end

        end

        if (params['discount_amount'] > 0)
          order.update!(
            discount_amount: params['discount_amount'],
            discount_by: params['discount_by']
            )
        end

        unless order.order_items.where("quantity != paid_quantity").exists?
          order.update!(waiting: false)
          order.table.update!(order_id: nil) if order.table
        end

        do_print(order.id)
        return true
      rescue Exception => e
        return false
      end
    end
  end

  def self.make_order(params)
    if params['id']
      order = Order.find(params['id'])
    else
      order = Order.create
    end
    order.transaction do
      begin
        #save or update order
        order.update name: params['name'], table_id: params['table_id'], servant_id: params['servant_id'], waiting: true

        #get taxs
        taxs  = Outlet.first.taxs;

        params[:order_items].each do |item_p|
          discount = Discount.where(product_id: item_p['product_id']).last
          discount = discount.nil? ? 0 : discount.amount.to_i
          tax_component = 0;
          taxs.each_pair do |name, amount|
            percentage = amount.to_f / 100
            tax_component += (percentage * item_p['price'].to_i).to_i
          end rescue true

          if item_p[:id].blank?
            item = order.order_items.create
          else
            item = order.order_items.find_by_id(item_p[:id])
          end

          item_params = {
            product_id:       item_p['product_id'],
            quantity:         item_p['quantity'],
            note:             item_p['note'].nil? ? '' : item_p['note'],
            void:             item_p['void'] || false,
            paid_amount:      ((item_p['price'].to_i * quantity) - (item_p['price'].to_i * discount)) + tax_component,
            tax_amount:       tax_component,
            discount_amount:  discount,
            void_note:        item_p['void_note'],
            take_away:        true,
            saved_choice:     item_p['choice'],
            void_by:          item_p['void_by'],
          }

          item.update!(item_params)
        end
        return true
      rescue Exception => e
        return false
      end
    end
  end

  def self.get_waiting_orders
    where("orders.table_id IS NULL AND orders.waiting IS TRUE")
  end

  def get_active_items
    order_items.where("quantity > paid_quantity")
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
      Table.update(params['table_id'], order_id: order.id)

      #get taxs
      taxs  = Outlet.first.taxs;

      # order_item
      params['products'].each do |prd|
        discount      = Discount.where(product_id: prd['id']).last
        discount      = discount.nil? ? 0 : discount.amount.to_i
        dsc_qty       = discount * prd['quantity'].to_i
        prices        = prd['price'].to_i * prd['quantity'].to_i
        prices_wo_dsc = prices - dsc_qty


        tax_component = 0;
        taxs.each_pair do |name, amount|
          percentage = amount.to_f / 100
          tax_component += (percentage * prices_wo_dsc).to_i
        end rescue true

        if prd['order_item_id']
          orderItem = OrderItem.find(prd['order_item_id'])
        else
          orderItem = OrderItem.create
        end

        orderItem.update(
          order_id:         order.id,
          product_id:       prd['id'],
          quantity:         prd['quantity'],
          note:             prd['note'].nil? ? '' : prd['note'].join(','),
          void:             prd['void'],
          paid_amount:      (tax_component + prices_wo_dsc),
          tax_amount:       tax_component,
          discount_amount:  dsc_qty,
          void_note:        prd['void_note'],
          take_away:        prd['take_away'],
          saved_choice:     prd['choice'],
          void_by:          prd['void_by']
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

  def do_print(params)
    #params :   pay_amount = cust_pay_amount
              # id = order_id
              # preview = 'yes' || 'no'

    params[:preview] = params[:preview] || 'yes'

    outlet = Outlet.first
    order  = Order.includes(:table, :order_items, :server).find(params[:id])

    text = center(true)
    text << outlet.name + "\n"
    text << outlet.address.gsub!("\n", " ") + "\n"
    text << "Telp:" + outlet.phone + "/" + outlet.mobile + "\n"
    text << "\n"

    text << emphasized(true)
    text << "Table : "
    text << order.table.name + "\n"
    text << emphasized(false)
    text << center(false)

    text << "Cust: "
    text << order.name
    text << 9.chr
    text << right(true)
    text << "Serv: "
    text << order.server.profile.name || order.server.profile.email
    text << right(false)
    text << "\n"

    text << center(true)
    text << line
    text << center(false)

    #order items
    sub_total      = 0
    discount_total = 0

    order.order_items.each do |item|
      print_qty = item.paid_quantity - item.printed_quantity
      if !item.void && item.paid && print_qty > 0
        prd_name = print_qty.to_s + " " + item.product.name.capitalize
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
          text << "   Discount: " + item.product.discount.name
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
      text << "  DISCOUNT"
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

      text << "  " + name.capitalize + " " + amount.to_s + "%"
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

    if params[:preview] == 'no'
      text << center(true)
      text << line
      text << center(false)

      text << emphasized(true)
      text << "  Pay"
      text << 9.chr
      text << right(true)
      text << number_to_currency(params[:pay_amount].to_i, unit: "Rp ", separator: ",", delimiter: ".", precision: 0)
      text << right(false)
      text << emphasized(false)
      text << "\n"

      text << emphasized(true)
      text << "  Change"
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

      if succeed && params[:preview] == 'no'
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
