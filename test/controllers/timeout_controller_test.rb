# frozen_string_literal: true

require "test_helper"

# Tests for session timeout check.
class TimeoutControllerTest < ActionDispatch::IntegrationTest
  test "should get check as public user" do
    get timeout_check_url(format: "js"), xhr: true
    assert_response :success
  end

  test "should get check as user" do
    login(users(:regular))
    get timeout_check_url(format: "js"), xhr: true
    assert_response :success
  end
end
