class V1::PrintsController < ApplicationController
  
  def bill
    orders = Order.find(params[:order_ids].split(','))
    payment = Payment.new(orders: orders, cashier_id: params[:cashier_id])
    binding.pry
    if Printer.print_bill(payment)
      render json: { message: 'Ok' }, status: 200
    else
      render json: { message: 'No data to print' }, status: 400
    end
  end

  def reprint
  	payment = Payment.find params[:payment_id]
  	if Printer.reprint(payment)
      render json: { message: 'Ok' }, status: 200
    else
      render json: { message: 'No data to print' }, status: 400
    end
  end

  def receipt
  	payment = Payment.find params[:payment_id]
  	if Printer.print_receipt(payment)
      render json: { message: 'Ok' }, status: 200
    else
      render json: { message: 'No data to print' }, status: 400
    end
  end

  def recap
  	user = User.find params[:user_id]
  	if Printer.print_recap(user)
      render json: { message: 'Ok' }, status: 200
    else
      render json: { message: 'No data to print' }, status: 400
    end
  end

  def send_bill_to_email
  	orders = Order.find(params[:order_ids].split(','))
    payment = Payment.new(orders: orders, cashier_id: params[:cashier_id])
    if ReceiptMailer.send_bill(payment, params[:email]).deliver_later
      render json: { message: 'Ok' }, status: 200
    else
      render json: { message: 'No data to print' }, status: 400
    end
  end

  def send_receipt_to_email
    payment = Payment.find params[:payment_id]
    if ReceiptMailer.send_receipt(payment, params[:email]).deliver_later
      render json: { message: 'Ok' }, status: 200
    else
      render json: { message: 'No data to print' }, status: 400
    end
  end

  def payment_params
  	params.require(:payment).permit!
  end

end
