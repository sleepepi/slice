# frozen_string_literal: true

require 'test_helper'

SimpleCov.command_name 'test:integration'

# Tests to assure that user navigation is working as intended
class NavigationTest < ActionDispatch::IntegrationTest
  fixtures :users

  def setup
    @valid = users(:valid)
    @deleted = users(:deleted)
  end

  test 'deleted users should be not be allowed to login' do
    get '/projects'
    assert_redirected_to new_user_session_path

    sign_in_as @deleted, '12345678'
    assert_equal new_user_session_path, path
    assert_equal I18n.t('devise.failure.inactive'), flash[:alert]
  end

  test 'root navigation redirected to login page' do
    get '/'
    assert_redirected_to new_user_session_path
    assert_equal I18n.t('devise.failure.unauthenticated'), flash[:alert]
  end

  test 'friendly url forwarding after login' do
    get '/projects'
    assert_redirected_to new_user_session_path

    sign_in_as @valid, '12345678'
    assert_equal '/projects', path
    assert_equal I18n.t('devise.sessions.signed_in'), flash[:notice]
  end
end
