# frozen_string_literal: true

require 'test_helper'

# Test to assure users can update their account settings
class AccountControllerTest < ActionDispatch::IntegrationTest
  setup do
    @regular_user = users(:valid)
    @project = projects(:one)
  end

  def user_params
    {
      first_name: 'FirstUpdate',
      last_name: 'LastUpdate',
      email: 'valid_update@example.com',
      emails_enabled: '0',
      theme: 'fall'
    }
  end

  test 'should get dashboard' do
    login(@regular_user)
    get dashboard_path
    assert_response :success
  end

  test 'should get dashboard and redirect to single project' do
    login(users(:site_one_viewer))
    get dashboard_path
    assert_not_nil assigns(:projects)
    assert_equal 1, assigns(:projects).count
    assert_redirected_to projects(:one)
  end

  test 'should get dashboard and redirect to root with invalid site invite token' do
    get '/site-invite/INVALID'
    assert_equal 'INVALID', session[:site_invite_token]
    assert_redirected_to new_user_session_path
    login(users(:valid))
    get dashboard_path
    assert_nil assigns(:site_user)
    assert_nil session[:site_invite_token]
    assert_response :success
  end

  test 'should get dashboard and redirect to project invite' do
    get "/invite/#{project_users(:pending_editor_invite).invite_token}"
    login(users(:two))
    assert_equal project_users(:pending_editor_invite).invite_token, session[:invite_token]
    get dashboard_path
    assert_redirected_to accept_project_users_path
  end

  test 'should get dashboard and redirect to project site invite' do
    get "/site-invite/#{site_users(:invited).invite_token}"
    login(users(:two))
    assert_equal site_users(:invited).invite_token, session[:site_invite_token]
    get dashboard_path
    assert_redirected_to accept_project_site_users_path(@project)
  end

  test 'should get site invite and remove invalid invite token' do
    login(@regular_user)
    get '/site-invite/imaninvalidtoken'
    assert_redirected_to root_path
    assert_nil session[:site_invite_token]
    assert_redirected_to root_path
  end

  test 'should get settings' do
    login(@regular_user)
    get settings_path
    assert_response :success
  end

  test 'should update settings' do
    login(@regular_user)
    post settings_path, params: { user: user_params }
    @regular_user.reload # Needs reload to avoid stale object
    assert_equal 'FirstUpdate', @regular_user.first_name
    assert_equal 'LastUpdate', @regular_user.last_name
    assert_equal 'valid_update@example.com', @regular_user.email
    assert_equal false, @regular_user.emails_enabled?
    assert_equal 'fall', @regular_user.theme
    assert_equal 'Settings saved.', flash[:notice]
    assert_redirected_to settings_path
  end

  test 'should update settings and enable email' do
    login(users(:send_no_email))
    post settings_path, params: { user: user_params.merge(emails_enabled: '1') }
    users(:send_no_email).reload # Needs reload to avoid stale object
    assert_equal true, users(:send_no_email).emails_enabled?
    assert_equal 'Settings saved.', flash[:notice]
    assert_redirected_to settings_path
  end

  test 'should update settings and disable email' do
    login(@regular_user)
    post settings_path, params: { user: { emails_enabled: '0' }, email: {} }
    @regular_user.reload # Needs reload to avoid stale object
    assert_equal false, @regular_user.emails_enabled?
    assert_equal 'Settings saved.', flash[:notice]
    assert_redirected_to settings_path
  end

  test 'should not update for user with blank name' do
    login(@regular_user)
    post settings_path, params: { user: { first_name: '' } }
    @regular_user.reload
    assert_equal 'FirstName', @regular_user.first_name
    assert_redirected_to settings_path
  end

  test 'should change password' do
    sign_in_as(@regular_user, 'password')
    patch change_password_path, params: {
      user: {
        current_password: 'password',
        password: 'newpassword',
        password_confirmation: 'newpassword'
      }
    }
    assert_equal 'Your password has been changed.', flash[:notice]
    assert_redirected_to settings_path
  end

  test 'should not change password as user with invalid current password' do
    sign_in_as(@regular_user, 'password')
    patch change_password_path, params: {
      user: {
        current_password: 'invalid',
        password: 'newpassword',
        password_confirmation: 'newpassword'
      }
    }
    assert_template 'settings'
    assert_response :success
  end

  test 'should not change password with new password mismatch' do
    sign_in_as(@regular_user, 'password')
    patch change_password_path, params: {
      user: {
        current_password: 'password',
        password: 'newpassword',
        password_confirmation: 'mismatched'
      }
    }
    assert_template 'settings'
    assert_response :success
  end
end
