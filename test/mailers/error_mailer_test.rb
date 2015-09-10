require 'test_helper'

class ErrorMailerTest < ActionMailer::TestCase
  test "error_email" do
    mail = ErrorMailer.error_email
    assert_equal "Error email", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
