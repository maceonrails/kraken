class ReceiptMailer < ApplicationMailer
	default from: "receipt@savenue.com"

	def send_bill(payment, email)
		@text = Printer.generate_bill(payment)
		@payment = payment
		mail to: email, subject: "Billing form S'Avenue"
	end

	def send_receipt(payment, email)
		@payment = payment
		mail to: email, subject: "Receipt form S'Avenue"
	end
end
