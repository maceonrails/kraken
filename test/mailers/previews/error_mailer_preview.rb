# Preview all emails at http://localhost:3000/rails/mailers/error_mailer
class ErrorMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/error_mailer/error_email
  def error_email
    ErrorMailer.error_email
  end

end
