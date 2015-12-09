class ReceiptMailer < ApplicationMailer
	default from: "receipt@kalisquare.com"

	def send_bill(payment, email)
		@text = Printer.generate_bill(payment)
		@payment = payment
		mail to: email, subject: "Billing from #{Outlet.first.name}"
	end

	def send_receipt(payment, email)
		@text = Printer.generate_bill(payment, receipt: true)
		@payment = payment
		mail to: email, subject: "Receipt from #{Outlet.first.name}"
	end
end
