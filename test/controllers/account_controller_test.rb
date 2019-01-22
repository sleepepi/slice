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
end
