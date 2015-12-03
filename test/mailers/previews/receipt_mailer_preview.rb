# Preview all emails at http://localhost:3000/rails/mailers/receipt_mailer
class ReceiptMailerPreview < ActionMailer::Preview
	def send_bill_preview
		payment = Payment.new
		payment.orders = Order.where(waiting: true)
		payment.cashier = User.cashier.first
		ReceiptMailer.send_bill(payment, "maceonrails@gmail.com")
	end
end
