# frozen_string_literal: true

require "test_helper"

# Test user settings pages.
class SettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @regular = users(:regular)
  end

  test "should get settings" do
    login(@regular)
    get settings_url
    assert_redirected_to settings_profile_url
  end

  test "should get profile for regular user" do
    login(@regular)
    get settings_profile_url
    assert_response :success
  end

  test "should not get profile for public user" do
    get settings_profile_url
    assert_redirected_to new_user_session_url
  end

  test "should update profile" do
    skip
    login(@regular)
    patch settings_update_profile_url, params: {
      user: {
        username: "regularupdate",
        description: "Staff Member"
      }
    }
    @regular.reload
    assert_equal "regularupdate", @regular.username
    assert_equal "Staff Member", @regular.description
    assert_equal "Profile successfully updated.", flash[:notice]
    assert_redirected_to settings_profile_url
  end

  test "should update profile picture" do
    login(@regular)
    patch settings_update_profile_picture_url, params: {
      user: {
        profile_picture: fixture_file_upload(file_fixture("rails.png"))
      }
    }
    @regular.reload
    assert_equal true, @regular.profile_picture.present?
    assert_equal "Profile picture successfully updated.", flash[:notice]
    assert_redirected_to settings_profile_url
  end

  test "should get account" do
    login(@regular)
    get settings_account_url
    assert_response :success
  end

  test "should update account" do
    login(@regular)
    patch settings_update_account_url, params: {
      user: { username: "newusername" }
    }
    assert_equal "Account successfully updated.", flash[:notice]
    assert_redirected_to settings_account_url
  end

  test "should update password" do
    sign_in_as(@regular, "password")
    patch settings_update_password_url, params: {
      user: {
        current_password: "password",
        password: "newpassword",
        password_confirmation: "newpassword"
      }
    }
    assert_equal "Your password has been changed.", flash[:notice]
    assert_redirected_to settings_account_url
  end

  test "should not update password as user with invalid current password" do
    sign_in_as(@regular, "password")
    patch settings_update_password_url, params: {
      user: {
        current_password: "invalid",
        password: "newpassword",
        password_confirmation: "newpassword"
      }
    }
    assert_response :success
  end

  test "should not update password with new password mismatch" do
    sign_in_as(@regular, "password")
    patch settings_update_password_url, params: {
      user: {
        current_password: "password",
        password: "newpassword",
        password_confirmation: "mismatched"
      }
    }
    assert_response :success
  end

  # test "should delete account" do
  #   login(@regular)
  #   assert_difference("User.current.count", -1) do
  #     delete settings_delete_account_url
  #   end
  #   assert_redirected_to root_url
  # end

  test "should get email" do
    login(@regular)
    get settings_email_url
    assert_response :success
  end

  test "should update email" do
    login(@regular)
    patch settings_update_email_url, params: { user: { email: "newemail@example.com" } }
    @regular.reload
    assert_equal "newemail@example.com", @regular.email
    assert_equal "Email successfully updated.", flash[:notice]
    assert_redirected_to settings_email_url

    # If confirmable is enabled.
    # assert_equal "regular@example.com", @regular.email
    # assert_equal "newemail@example.com", @regular.unconfirmed_email
    # assert_equal I18n.t("devise.confirmations.send_instructions"), flash[:notice]
    # assert_redirected_to settings_email_url
  end

  test "should get interface settings" do
    login(@regular)
    get settings_interface_url
    assert_response :success
  end

  test "should update interface settings" do
    login(@regular)
    patch settings_update_interface_url, params: { user: { theme: "winter", sound_enabled: "1" } }
    @regular.reload
    assert_equal true, @regular.sound_enabled?
    assert_equal "winter", @regular.theme
    assert_equal "Settings successfully updated.", flash[:notice]
    assert_redirected_to settings_interface_url
  end

  test "should get notification settings" do
    login(@regular)
    get settings_notifications_url
    assert_response :success
  end

  test "should update notification settings" do
    login(@regular)
    patch settings_update_notifications_url, params: { user: { emails_enabled: "1" } }
    @regular.reload
    assert_equal true, @regular.emails_enabled?
    assert_equal "Settings successfully updated.", flash[:notice]
    assert_redirected_to settings_notifications_url
  end
end
