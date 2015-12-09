class V1::PaymentsController < V1::BaseController

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
