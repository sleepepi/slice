require 'test_helper'

SimpleCov.command_name "test:units"

class UserTest < ActiveSupport::TestCase
  test "should get reverse name" do
    assert_equal 'LastName, FirstName', users(:valid).reverse_name
  end

  test "should apply omniauth" do
    assert_not_nil users(:valid).apply_omniauth({ 'info' => {'email' => 'Email', 'first_name' => 'FirstName', 'last_name' => 'LastName' } })
  end

  test "should create an omniauth user without a password" do
    u = User.new
    omniauth = { 'info' => { 'first_name' => 'First Name', 'last_name' => 'Last Name', 'email' => 'omniauth@example.com' }, 'provider' => 'google_apps', 'uid' => 'omniauth@example.com' }
    u.apply_omniauth(omniauth)
    assert_difference('User.current.count') do
      assert_difference('Authentication.count') do
        u.save
      end
    end
    assert u.errors.blank?
    assert_equal "First Name", u.first_name
    assert_equal "Last Name", u.last_name
    assert_equal "omniauth@example.com", u.email
  end

  # test "should allow send_email for email_on?" do
  #   assert_equal true, users(:valid).email_on?(:send_email)
  # end

  # test "should not allow send_email for email_on?" do
  #   assert_equal false, users(:two).email_on?(:send_email)
  # end
end
