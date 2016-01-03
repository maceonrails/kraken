class V1::PaymentsController < V1::BaseController

  def search
    if params[:type]
      puts '==========='
      puts 'today'
      payments = Payment
                .includes(:orders, orders: :order_items)
                .where(created_at: Date.today.beginning_of_day..Date.today.end_of_day)
                .all
      payments = payments.joins(:cashier).where("users.outlet_id = ?", params[:outlet_id]) if params[:outlet_id].present?
      payments = payments.joins(orders: {order_items: :product}).where("products.tenant_id = ?", params[:tenant_id]) if params[:tenant_id].present?
      @payments = payments
      @total  = @payments.count || 0
    elsif params[:dateStart] && params[:dateEnd]
      query  = params[:data] || ''
      payments = Payment.where(created_at: (Date.parse(params[:dateStart])).beginning_of_day..(Date.parse(params[:dateEnd])).end_of_day)
                    
      if query.downcase.include?("order")
        payments = payments.joins(orders: :table).where("tables.name ILIKE :q", q: "%#{query.split(" ").last}%")
      else
        payments = payments.where("payments.receipt_number LIKE ? OR payments.note LIKE ?", "%#{query}%", "%#{query}%")
      end
      
      payments = payments.joins(:cashier).where("users.outlet_id = ?", params[:outlet_id]) if params[:outlet_id].present?
      payments = payments.joins(orders: {order_items: :product}).where("products.tenant_id = ?", params[:tenant_id]) if params[:tenant_id].present?
      payments = payments.where("payments.cashier_id = ?", params[:cashier_id]) if params[:cashier_id].present?
      payments = payments.order("payments.created_at DESC")
      payments = payments.uniq

      @resume = {}
      @resume[:cash_amount] = payments.sum("payments.total::float - (payments.debit_amount::float + payments.credit_amount::float)")
      @resume[:debit_amount] = payments.sum("payments.debit_amount::float")
      @resume[:credit_amount] = payments.sum("payments.credit_amount::float")
      @resume[:discount_amount] = payments.sum("payments.discount_amount::float")
      @resume[:total] = payments.sum("payments.total::float")

      if page_params[:page_size] == 'all'
        @payments = payments.page(page_params[:page]).per(Payment.count)
      else
        @payments = payments.page(page_params[:page]).per(page_params[:page_size])
      end
      @total  = payments.count || 0
    else
      render json: {message: 'payment not found'}, status: 404
    end
  end

  def show
  end

	def create
    if Payment.pay(pay_params)
      render json: { message: 'Ok' }, status: 201
    else
      binding.pry
      render json: { message: "pay order failed" }, status: 409
    end
	end



	def pay_params
    params.permit(:id, :servant_id, :table_id, :name, :discount_by, :discount_amount, :discount_percent, :void, :cashier_id,
      :credit_amount, :debit_amount, :cash_amount, :debit_name, :credit_name, :credit_number, :debit_number, :type,
      :pay_amount, :sub_total, :total, :paid_amount, :return_amount, :remain_amount, :email, :print, :note, orders: order_params
    )
  end

  def order_item_params
  	[
  		"order_id", "id", "product_id", "quantity", "choice_id", "note", "payment_id", "served", "void", "created_at", 
  		"updated_at", "paid", "void_note", "void_quantity", "saved_choice", "take_away", "void_by", "paid_quantity", 
  		"printed_quantity", "pay_quantity", "oc_quantity", "oc_by", "oc_note", "paid_amount", "tax_amount", 
  		"discount_amount", "discount_id", "price", "discount"
  	]
  end

  def order_params
  	[
    	:id, :name, :waiting, :queue_number, :table_id, :servant_id, :struck_id, :discount_percent, :cash_amount, :debit_amount, 
    	:credit_amount, :credit_name, :credit_number, :debit_name, :debit_number, :table_name, :table_location, 
    	:pay_amount, :return_amount, :total_discount, :discount_amount, order_items: order_item_params
    ]
  end
end
