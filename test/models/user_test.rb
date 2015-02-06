require 'test_helper'

SimpleCov.command_name "test:models"

class UserTest < ActiveSupport::TestCase
  test "should get reverse name" do
    assert_equal 'LastName, FirstName', users(:valid).reverse_name
  end

  # test "should allow send_email for email_on?" do
  #   assert_equal true, users(:valid).email_on?(:send_email)
  # end

  # test "should not allow send_email for email_on?" do
  #   assert_equal false, users(:two).email_on?(:send_email)
  # end
end
