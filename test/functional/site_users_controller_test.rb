require 'test_helper'

class SiteUsersControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @site_user = site_users(:one)
  end

  test "should accept site user" do
    login(users(:two))
    get :accept, invite_token: site_users(:invited).invite_token

    assert_not_nil assigns(:site_user)
    assert_equal users(:two), assigns(:site_user).user
    assert_equal "You have been successfully been added to the site.", flash[:notice]
    assert_redirected_to assigns(:site_user).site
  end

  test "should accept existing site user" do
    get :accept, invite_token: site_users(:two).invite_token

    assert_not_nil assigns(:site_user)
    assert_equal users(:valid), assigns(:site_user).user
    assert_equal "You have already been added to #{assigns(:site_user).site.name}.", flash[:notice]
    assert_redirected_to assigns(:site_user).site
  end

  test "should not accept invalid token for site user" do
    get :accept, invite_token: 'imaninvalidtoken'

    assert_nil assigns(:site_user)
    assert_equal 'Invalid invitation token.', flash[:alert]
    assert_redirected_to root_path
  end

  test "should not accept site user if invite token is already claimed" do
    login(users(:two))
    get :accept, invite_token: 'validintwo'

    assert_not_nil assigns(:site_user)
    assert_not_equal users(:two), assigns(:site_user).user
    assert_equal "This invite has already been claimed.", flash[:alert]
    assert_redirected_to root_path
  end




  test "should create site_user" do
    assert_difference('SiteUser.count') do
      post :create, site_user: { site_id: @site_user.site_id }, invite_email: 'invite@example.com', format: 'js'
    end

    assert_template 'index'
    assert_response :success
  end

  test "should not create site user with invalid site id" do
    assert_difference('SiteUser.count', 0) do
      post :create, site_user: { site_id: -1 }, invite_email: 'invite@example.com', format: 'js'
    end

    assert_nil assigns(:site_user)
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
