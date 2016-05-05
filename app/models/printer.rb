class Printer < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  after_create :update_default

  def self.print_bill(payment)
    self.do_print(payment, preview: true)
  end

  def self.reprint(payment)
    self.do_print(payment, reprint: true)
  end

  def self.print_receipt(payment)
    self.do_print(payment, receipt: true)
  end

  def self.generate_bill payment, opts = {}
    text ||= ''

    outlet = payment.cashier.outlet
    text << center_line(outlet.name.to_s)
    text << "\n"
    text << center_line(outlet.address.to_s.gsub!("\n", " ").to_s)
    text << "\n"
    text << center_line("Telp: " + outlet.phone.to_s + ("/" + outlet.mobile.to_s if outlet.mobile).to_s)
    text << "\n"
    
    text << center_line(Time.now.strftime("%d %B %Y %H:%M").to_s + "\n")

    if payment.receipt_number
      text << "\n"
      text << per_line("Receipt ID : #{payment.receipt_number}")
    end
    text << "\n"
    text << per_line("No Order   : #{payment.orders.map {|a| a.table.name }.join(',')}")
    text << "\n"
    text << per_line("Cashier    : #{payment.cashier.try(:profile).try(:name) || payment.cashier.try(:email) || outlet.name}")
    text << "\n"
    text << double_line
    text << "\n"

    payment.orders.each do |order|
      text << "Order no #{order.table.name} :\n"
      order.order_items.each do |item|
        unless item.active_quantity == 0
          text << print_line("#{item.active_quantity} #{item.product.name}", item.total_price)
        end
      end
    end
    text << "\n"
    text << print_line("Sub Total", payment.sub_total)
    payment.cashier.outlet.taxs.each do |tax, amount|
      text << print_line("#{tax}", amount.to_f/100*payment.sub_total)
    end
    if payment.discount_amount.to_f > 0 
      text << print_line("Order Discount", payment.discount_amount)
    end
    if payment.discount_products.to_f > 0 
      text << print_line("Product Discounts", payment.discount_products)
    end

    text << line
    text << print_line("TOTAL", payment.total)
    text << "\n"

    if opts[:receipt] || opts[:reprint]
      if payment.cash_amount.to_i > 0
        text << print_line("Cash", payment.cash_amount)
      end

      if payment.debit_amount.to_i > 0
        text << print_line("Debit", payment.debit_amount)
      end

      if payment.credit_amount.to_i > 0
        text << print_line("Credit", payment.credit_amount)
      end

      text << line
      text << print_line("PAY", payment.pay_amount)

      text << "\n"
      text << print_line("CHANGE", payment.return_amount < 0 ? 0 : payment.return_amount)
      text << "\n"

      if payment.debit_amount.to_i > 0
        text << per_line(" *DEBIT CARD #{payment.debit_name}: ****#{payment.debit_number.to_s[-4, 4]}")
        text << "\n"
      end

      if payment.credit_amount.to_i > 0
        text << per_line(" *CREDIT CARD #{payment.credit_name}: ****#{payment.credit_number.to_s[-4, 4]}")
        text << "\n"
      end
    end

    if opts[:reprint]
      text << center_line("--REPRINT--")
      text << "\n"
    end

    text << double_line

    text << center_line("Thanks For Your Visit")
    text << "\n"
    text << center_line("Till Next Time")
    text << "\n"
    text << center_line("Powered by eresto.co.id")
    text << "\n\n\n\n\n\n\n\n\n"

    return text
  end

  def self.print_recap(user)
    start_login = user.start_login
    text = ''
    recap = Payment.recap(user)

    text << "Rekap Omzet Kasir\n"
    text << double_line
    text << "\n"
    text << "Kasir   : "+ ( user.try(:name) || user.try(:email) ) +"\n"
    text << "Tanggal : "+ (Date.today.strftime("%d %B %Y").to_s) + "\n"
    # text << "s/d   : "+ Time.now.strftime("%d %B %Y %H:%M").to_s + "\n"
    text << double_line
    text << "\n\n"

    text << print_line("Saldo Awal")
    text << print_line("CASH", recap.total_cash)
    text << line
    text << print_line("Saldo Akhir(Cash)", recap.total_cash)
    text << print_line("NON CASH", recap.total_non_cash)
    text << line
    text << print_line("Total Transaksi", recap.total_transaction)
    text << "\n"

    text << print_line("Penjualan", recap.total_sales)
    user.outlet.taxs.each do |tax, amount|
      text << print_line("Total #{tax}", (amount.to_f/100 * (recap.total_non_cash + recap.total_cash)).to_f)
    end
    text << line
    text << print_line("Discount Produk", recap.total_product_discount)
    text << print_line("Discount Order", recap.total_order_discount)
    text << line
    text << print_line("", recap.total_transaction)
    text << "\n"

    text << "*** Jenis Pembayaran ***\n"
    text << print_line("(+) Cash", recap.total_cash)
    text << print_line("(+) Debit", recap.total_debit)
    text << print_line("(+) Credit", recap.total_credit)
    text << print_line("(+) Officer Check", recap.total_oc)
    text << line
    text << print_line("Total Trans.", recap.total_transaction)
    text << line
    text << "\n"

    text << "Jumlah yang terjual : \n"
    text << line
    text << "qty | Jenis           Amount\n"
    text << line

    recap.total_per_category.each do |cat|
      text << print_line("#{cat.quantity} #{cat.name}", cat.amount)
    end
    text << line
    text << "\n"

    text << print_line("Jumlah struk", recap.count, '')
    text << print_line("Rata2 per struk", (recap.total_transaction.to_i / recap.count rescue 0))
    text << print_line("Jumlah tamu", recap.total_pax, '')
    text << print_line("Rata2 per tamu", (recap.total_transaction.to_i / recap.total_pax rescue 0))
    text << "\n"
    text << print_line("Total", recap.total_transaction)

    text << "\n\n"

    text << "Yg menyerahkan         Yg menerima"
    text << "\n\n\n\n\n\n"
    text << "--------------         -------------"
    text << "\n\n"

    text << double_line

    text << "\n"
    text << center_line("#{user.outlet.name} Print Rekap")
    text << "\n\n\n\n\n\n\n\n\n"

    succeed = true
    puts "==================="
    puts "start printing "
    puts "\n"
    puts text.to_s

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
    recap.update_all(closing_time: Time.now) if succeed
    return { status: succeed }
  end

  def self.do_print(payment, opts = { preview: true })
    text = ''
    text << generate_bill(payment, opts)

    succeed = true
    puts "==================="
    puts "start printing "
    puts "\n"
    puts text.to_s

    if payment.sub_total > 0
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
        payment.order_items.each do |item|
          item.update(printed_quantity: item.paid_quantity)
        end
      end
    end

    return { status: succeed, printed: payment.sub_total > 0}
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

  def self.line(number = 40)
    "-" * number + "\n"
  end

  def self.double_line(number = 40)
    "=" * number + "\n"
  end

  def self.repeat(char = '-', number = 40, new_line = true)
    result = char * number
    new_line ? result : result + "\n"
  end

  def self.per_line(text, number = 40)
    part1, part2 = text.slice!(0...number), text
    part2 = (" " * (part1.index(":") + 2)) + part2
    return part1.to_s + (part2.present? ? "\n" + part2.to_s : "")
  end

  def self.center_line(text, number = 40)
    whitespace = number - text.length
    return (" " * (whitespace/2)) + text
  end

  def self.pull_left(text, currency = 'Rp.', length = 23)
    (text.length <= length ? text + " " * (length - text.length) : text.truncate(length, :omission => '')) + ": " + currency
  end

  def self.pull_right(text, length = 11)
    amount = number_to_currency(text, unit: "", separator: ",", delimiter: ".", precision: 0)
    return " " * (length - amount.length) + amount
  end

  def self.print_line(text, amount = 0, currency = 'Rp.')
    result = ''
    result << pull_left(text, currency)
    result << pull_right(amount, 40 - result.length)
    if text[23..-1].present?
      result << "\n" 
      result << "  " + text[23..-1].to_s
    end
    result << "\n"
  end

  def self.print_amount(amount)
    result = ''
    result << right(true)
    result << number_to_currency(amount, unit: "", separator: ",", delimiter: ".", precision: 0)
    result << right(false)
  end

  def self.number_to_currency(amount, opts)
    ActionController::Base.helpers.number_to_currency(amount, opts)
  end

  private
    def update_default
      if self.default
        Printer.where.not(id: self.id).update_all(default: false)
      end
    end
end
