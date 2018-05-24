# frozen_string_literal: true

require "test_helper"

# Test to assure users can update their account settings
class AccountControllerTest < ActionDispatch::IntegrationTest
  setup do
    @regular = users(:regular)
    @project = projects(:one)
  end

  def user_params
    {
      full_name: "FirstUpdate LastUpdate",
      email: "regular_update@example.com",
      emails_enabled: "0",
      theme: "spring"
    }
  end

  test "should get dashboard" do
    login(@regular)
    get dashboard_url
    assert_response :success
  end

  test "should get dashboard and redirect to single project" do
    login(users(:site_one_viewer))
    get dashboard_url
    assert_not_nil assigns(:projects)
    assert_equal 1, assigns(:projects).count
    assert_redirected_to projects(:one)
  end

  test "should get dashboard and redirect to root with invalid site invite token" do
    get "/site-invite/INVALID"
    assert_equal "INVALID", session[:site_invite_token]
    assert_redirected_to new_user_session_url
    login(users(:regular))
    get dashboard_url
    assert_nil assigns(:site_user)
    assert_nil session[:site_invite_token]
    assert_response :success
  end

  test "should get dashboard and redirect to project invite" do
    get "/invite/#{project_users(:pending_editor_invite).invite_token}"
    login(users(:two))
    assert_equal project_users(:pending_editor_invite).invite_token, session[:invite_token]
    get dashboard_url
    assert_redirected_to accept_project_users_url
  end

  test "should get dashboard and redirect to project site invite" do
    get "/site-invite/#{site_users(:invited).invite_token}"
    login(users(:two))
    assert_equal site_users(:invited).invite_token, session[:site_invite_token]
    get dashboard_url
    assert_redirected_to accept_project_site_users_url(@project)
  end

  test "should get site invite and remove invalid invite token" do
    login(@regular)
    get "/site-invite/imaninvalidtoken"
    assert_redirected_to root_url
    assert_nil session[:site_invite_token]
    assert_redirected_to root_url
  end

  test "should get settings" do
    login(@regular)
    get settings_url
    assert_response :success
  end

  test "should update settings" do
    login(@regular)
    post settings_url, params: { user: user_params }
    @regular.reload # Needs reload to avoid stale object
    assert_equal "FirstUpdate LastUpdate", @regular.full_name
    assert_equal "regular_update@example.com", @regular.email
    assert_equal false, @regular.emails_enabled?
    assert_equal "spring", @regular.theme
    assert_equal "Settings saved.", flash[:notice]
    assert_redirected_to settings_url
  end

  test "should update settings and enable email" do
    login(users(:send_no_email))
    post settings_url, params: { user: user_params.merge(emails_enabled: "1") }
    users(:send_no_email).reload # Needs reload to avoid stale object
    assert_equal true, users(:send_no_email).emails_enabled?
    assert_equal "Settings saved.", flash[:notice]
    assert_redirected_to settings_url
  end

  test "should update settings and disable email" do
    login(@regular)
    post settings_url, params: { user: { emails_enabled: "0" }, email: {} }
    @regular.reload # Needs reload to avoid stale object
    assert_equal false, @regular.emails_enabled?
    assert_equal "Settings saved.", flash[:notice]
    assert_redirected_to settings_url
  end

  test "should not update for user with blank full name" do
    login(@regular)
    post settings_url, params: { user: { full_name: "" } }
    @regular.reload
    assert_equal "FirstName LastName", @regular.full_name
    assert_redirected_to settings_url
  end

  test "should change password" do
    sign_in_as(@regular, "password")
    patch change_password_url, params: {
      user: {
        current_password: "password",
        password: "newpassword",
        password_confirmation: "newpassword"
      }
    }
    assert_equal "Your password has been changed.", flash[:notice]
    assert_redirected_to settings_url
  end

  test "should not change password as user with invalid current password" do
    sign_in_as(@regular, "password")
    patch change_password_url, params: {
      user: {
        current_password: "invalid",
        password: "newpassword",
        password_confirmation: "newpassword"
      }
    }
    assert_template "settings"
    assert_response :success
  end

  test "should not change password with new password mismatch" do
    sign_in_as(@regular, "password")
    patch change_password_url, params: {
      user: {
        current_password: "password",
        password: "newpassword",
        password_confirmation: "mismatched"
      }
    }
    assert_template "settings"
    assert_response :success
  end

  test "should update profile picture" do
    login(@regular)
    patch update_profile_picture_url, params: {
      user: {
        profile_picture: fixture_file_upload("../../test/support/images/rails.png")
      }
    }
    @regular.reload
    assert_equal true, @regular.profile_picture.present?
    assert_equal "Profile picture successfully updated.", flash[:notice]
    assert_redirected_to settings_url
  end
end
