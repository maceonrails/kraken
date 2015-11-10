class Printer < ActiveRecord::Base
  after_create :update_default

  def self.print_order(params, opts = { preview: true })
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

      pay_amnt = params[:debit_amount].to_i + params[:cash_amount].to_i + params[:credit_amount].to_i

      text << emphasized(true)
      text << "  PAY"
      text << 9.chr
      text << right(true)
      text << number_to_currency(pay_amnt.to_i, unit: "Rp ", separator: ",", delimiter: ".", precision: 0)
      text << right(false)
      text << emphasized(false)
      text << "\n"

      text << emphasized(true)
      text << "  CHANGE"
      text << 9.chr
      text << right(true)
      text << number_to_currency((pay_amnt.to_i - grand_total), unit: "Rp ", separator: ",", delimiter: ".", precision: 0)
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

  def self.print_rekap(user)
    start_login = user.start_login
    text = center(true)

    text << "Rekap Omzet Kasir\n"
    text << "============================\n\n"
    text << center(false)
    text << "Kasir     : "+ ( user.try(:name) || user.try(:email) ) +"\n"
    text << "Mulai jam : "+ start_login.strftime("%d %B %Y %H:%M").to_s rescue '' + "\n"
    text << "s/d jam   : "+ Time.now.strftime("%d %B %Y %H:%M").to_s + "\n\n\n"

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
  end

  def self.breaks
    return "\n\n"
  end

  def self.recursive_symbolize_keys(h)
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

  def self.emphasized(on)
    text = 27.chr
    text << 33.chr
    if on
      text << 8.chr
    else
      text << 0.chr
    end
    return text
  end

  def self.center(on)
    text = 27.chr
    text << 97.chr
    if on
      text << 1.chr
    else
      text << 0.chr
    end
    return text
  end

  def self.right(on)
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

  def self.line
    return "---------------------------------\n"
  end

  private
    def update_default
      if self.default
        Printer.where.not(id: self.id).update_all(default: false)
      end
    end
end
