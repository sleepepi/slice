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
    assert_redirected_to projects(:one)
  end

  test "should get dashboard and redirect to root with invalid site invite token" do
    get "/site-invite/INVALID"
    assert_equal "INVALID", session[:site_invite_token]
    assert_redirected_to new_user_session_url
    login(users(:regular))
    get dashboard_url
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
end
