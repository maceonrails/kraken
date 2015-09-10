class ErrorMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.error_mailer.error_email.subject
  #
  def error_email(code, message, body)
    @outlet  = Outlet.first
    @code    = code
    @message = message
    mail to: "ev.kristian@gmail.com", subject: 'Error encounter on '+@outlet.name.to_s
  end
end
