require 'test_helper'

class V1::PrintsControllerTest < ActionController::TestCase
  test "should get bill" do
    get :bill
    assert_response :success
  end

  test "should get reprint" do
    get :reprint
    assert_response :success
  end

  test "should get receipt" do
    get :receipt
    assert_response :success
  end

  test "should get recap" do
    get :recap
    assert_response :success
  end

end
