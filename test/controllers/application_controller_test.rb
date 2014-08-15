require 'test_helper'

class ApplicationControllerTest < ActionController::TestCase
  setup do
    # Nothing
  end

  test "should parse time" do
    assert_equal "12:00:00", @controller.send(:parse_time, "12pm")
  end

  test "should parse invalid time" do
    assert_equal "", @controller.send(:parse_time, "abc")
  end

  test "should get theme" do
    get :theme
    assert_response :success
  end

end
