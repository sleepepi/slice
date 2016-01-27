# frozen_string_literal: true

require 'test_helper'

# Tests for session timeout check
class TimeoutControllerTest < ActionController::TestCase
  test 'should get check as public viewer' do
    xhr :get, :check, format: 'js'
    assert_response :success
  end

  test 'should get check as user' do
    login(users(:valid))
    xhr :get, :check, format: 'js'
    assert_response :success
  end
end
