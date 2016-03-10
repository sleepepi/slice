# frozen_string_literal: true

require 'test_helper'

SimpleCov.command_name 'test:controllers'

# Tests to make sure users can access account settings, and reset password, and
# that admins can edit and update existing users.
class UsersControllerTest < ActionController::TestCase
  setup do
    @user = users(:valid)
  end

  test 'should update settings and enable email' do
    login(users(:admin))
    post :update_settings, user: { emails_enabled: '1' }, email: {}
    users(:admin).reload # Needs reload to avoid stale object
    assert_equal true, users(:admin).emails_enabled?
    assert_equal 'Email settings saved.', flash[:notice]
    assert_redirected_to settings_path
  end

  test 'should update settings and disable email' do
    login(users(:admin))
    post :update_settings, user: { emails_enabled: '0' }, email: {}
    users(:admin).reload # Needs reload to avoid stale object
    assert_equal false, users(:admin).emails_enabled?
    assert_equal 'Email settings saved.', flash[:notice]
    assert_redirected_to settings_path
  end

  test 'should update theme for user' do
    login(users(:admin))
    post :update_theme, user: { theme: 'winter' }
    users(:admin).reload
    assert_equal 'winter', users(:admin).theme
    assert_equal 'Settings were successfully updated.', flash[:notice]
    assert_redirected_to settings_path
  end

  test 'should not update for user with blank name' do
    login(users(:admin))
    post :update_theme, user: { first_name: '' }
    users(:admin).reload
    assert_equal 'System', users(:admin).first_name
    assert_equal 'Settings were not successfully updated.', flash[:alert]
    assert_redirected_to settings_path
  end

  test 'should change password' do
    login(users(:admin))
    patch :change_password, user: {
      current_password: 'password',
      password: 'newpassword',
      password_confirmation: 'newpassword'
    }
    assert_equal 'Your password has been changed.', flash[:notice]
    assert_redirected_to settings_path
  end

  test 'should not change password as user with invalid current password' do
    login(users(:admin))
    patch :change_password, user: {
      current_password: 'invalid',
      password: 'newpassword',
      password_confirmation: 'newpassword'
    }
    assert_template 'settings'
    assert_response :success
  end

  test 'should not change password with new password mismatch' do
    login(users(:admin))
    patch :change_password, user: {
      current_password: 'password',
      password: 'newpassword',
      password_confirmation: 'mismatched'
    }
    assert_template 'settings'
    assert_response :success
  end

  test 'should get settings' do
    login(users(:admin))
    get :settings
    assert_response :success
  end

  test 'should get index as admin' do
    login(users(:admin))
    get :index
    assert_not_nil assigns(:users)
    assert_response :success
  end

  test 'should get index for autocomplete' do
    login(users(:valid))
    get :index, format: 'json'
    assert_not_nil assigns(:users)
    assert_response :success
  end

  test 'should not get index for non-system admin' do
    login(users(:valid))
    get :index
    assert_nil assigns(:users)
    assert_equal 'You do not have sufficient privileges to access that page.', flash[:alert]
    assert_redirected_to root_path
  end

  test 'should not get index with pagination for non-system admin' do
    login(users(:valid))
    get :index, format: 'js'
    assert_nil assigns(:users)
    assert_equal 'You do not have sufficient privileges to access that page.', flash[:alert]
    assert_redirected_to root_path
  end

  test 'should get invite for regular user' do
    login(users(:valid))
    get :invite, q: 'associated'
    users_json = JSON.parse(response.body)
    assert_equal 'associated@example.com', users_json.first['value']
    assert_equal 'Associated User', users_json.first['name']
    assert_response :success
  end

  test 'should show user as admin' do
    login(users(:admin))
    get :show, id: @user
    assert_response :success
  end

  test 'should get edit as admin' do
    login(users(:admin))
    get :edit, id: @user
    assert_response :success
  end

  test 'should not get edit as regular user' do
    login(users(:valid))
    get :edit, id: @user
    assert_redirected_to root_path
  end

  test 'should update user as admin' do
    login(users(:admin))
    patch :update, id: @user,
                 user: {
                   first_name: 'FirstName',
                   last_name: 'LastName',
                   email: 'valid_updated_email@example.com',
                   system_admin: false
                 }
    assert_redirected_to user_path(assigns(:user))
  end

  test 'should not update user with blank name' do
    login(users(:admin))
    patch :update, id: @user, user: { first_name: '', last_name: '' }
    assert_not_nil assigns(:user)
    assert_template 'edit'
  end

  test 'should not update user with invalid id' do
    login(users(:admin))
    patch :update, id: -1,
                 user: {
                   first_name: 'FirstName',
                   last_name: 'LastName',
                   email: 'valid_updated_email@example.com',
                   system_admin: false
                 }
    assert_nil assigns(:user)
    assert_redirected_to users_path
  end

  test 'should destroy user as admin' do
    login(users(:admin))
    assert_difference('User.current.count', -1) do
      delete :destroy, id: @user
    end

    assert_redirected_to users_path
  end
end
