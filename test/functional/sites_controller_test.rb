require 'test_helper'

class SitesControllerTest < ActionController::TestCase

  setup do
    login(users(:valid))
  end

  test "should get index" do
    get :dashboard
    assert_response :success
  end

end
