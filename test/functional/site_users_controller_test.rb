require 'test_helper'

class SiteUsersControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @site_user = site_users(:one)
  end

  test "should create site_user" do
    assert_difference('SiteUser.count') do
      post :create, site_user: { site_id: @site_user.site_id }, invite_email: 'invite@example.com', format: 'js'
    end

    assert_template 'index'
    assert_response :success
  end

  test "should destroy site_user" do
    assert_difference('SiteUser.count', -1) do
      delete :destroy, id: @site_user, format: 'js'
    end

    assert_template 'index'
    assert_response :success
  end
end
