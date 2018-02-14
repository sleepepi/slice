# frozen_string_literal: true

require "application_system_test_case"

# System tests for devise pages.
class DeviseTest < ApplicationSystemTestCase
  test "visit registration page" do
    visit new_user_registration_url
    screenshot("visit-registration-page")
    assert_selector "div", text: "Create your account"
  end

  test "visit login page" do
    visit new_user_session_url
    screenshot("visit-login-page")
    assert_selector "div", text: "Sign in"
  end

  test "visit password reset page" do
    visit new_user_password_url
    screenshot("visit-password-reset-page")
    assert_selector "div", text: "Reset password"
  end

  test "visit password change page" do
    token = users(:admin).send(:set_reset_password_token)
    visit edit_user_password_url(reset_password_token: token)
    screenshot("visit-password-change-page")
    assert_selector "div", text: "Change password"
  end

  test "visit unlock page" do
    visit new_user_unlock_url
    screenshot("visit-unlock-page")
    assert_selector "div", text: "Unlock account"
  end
end
