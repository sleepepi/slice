# frozen_string_literal: true

require "test_helper"

# Tests to assure that passwords can be reset.
class PasswordTest < ActionDispatch::IntegrationTest
  test "should get forgot your password page" do
    get new_user_password_path
    assert_response :success
  end

  test "should request password reset" do
    post user_password_path, params: {
      user: { email: users(:regular).email }
    }
    assert_equal I18n.t("devise.passwords.send_instructions"), flash[:notice]
    assert_redirected_to new_user_session_path
  end

  test "should get reset password page" do
    token = users(:regular).send(:set_reset_password_token)
    get edit_user_password_path(reset_password_token: token)
    assert_response :success
  end

  test "should reset password" do
    token = users(:regular).send(:set_reset_password_token)
    patch user_password_path, params: {
      user: {
        reset_password_token: token,
        password: "NEWpassword1",
        password_confirmation: "NEWpassword1"
      }
    }
    assert_equal I18n.t("devise.passwords.updated"), flash[:notice]
    assert_redirected_to root_url
  end
end
