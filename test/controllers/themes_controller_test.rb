# frozen_string_literal: true

require "test_helper"

# Tests to assure theme configuration pages load.
class ThemesControllerTest < ActionDispatch::IntegrationTest
  test "should get dashboard test" do
    get themes_dashboard_test_url
    assert_response :success
  end

  test "should get full test" do
    get themes_full_test_url
    assert_response :success
  end

  test "should get menu test" do
    get themes_menu_test_url
    assert_response :success
  end

  test "should get transition test" do
    get themes_transition_test_url
    assert_response :success
  end
end
