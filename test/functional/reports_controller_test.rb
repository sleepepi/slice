require 'test_helper'

class ReportsControllerTest < ActionController::TestCase

  setup do
    login(users(:valid))
  end

  test "should get index" do
    get :index
    assert_response :success
  end

end
