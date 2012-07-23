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

    assert_not_nil assigns(:site_user)
    assert_not_nil assigns(:site)

    assert_template 'index'
    assert_response :success
  end

  test "should not destroy site_user as a site user" do
    login(users(:site_one_user))
    assert_difference('SiteUser.count', 0) do
      delete :destroy, id: @site_user, format: 'js'
    end

    assert_not_nil assigns(:site_user)
    assert_nil assigns(:site)

    assert_response :success
  end

  test "should destroy site_user if signed in user is the selected site user" do
    login(users(:site_one_user))
    assert_difference('SiteUser.count', -1) do
      delete :destroy, id: site_users(:site_user), format: 'js'
    end

    assert_not_nil assigns(:site_user)
    assert_not_nil assigns(:site)

    assert_template 'index'
    assert_response :success
  end
end
