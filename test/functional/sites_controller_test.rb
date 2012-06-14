require 'test_helper'

class SitesControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @site = sites(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:sites)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create site" do
    assert_difference('Site.count') do
      post :create, site: { description: 'Second Site on Project One', emails: 'email@example.com', name: 'Site Two', project_id: projects(:one).id, prefix: 'Prefix' }
    end

    assert_redirected_to site_path(assigns(:site))
  end

  test "should not create site for invalid project" do
    assert_difference('Site.count', 0) do
      post :create, site: { description: 'Second Site on Project One', emails: 'email@example.com', name: 'Site Two', project_id: projects(:four).id, prefix: 'Prefix' }
    end

    assert_not_nil assigns(:site)
    assert_equal ["can't be blank"], assigns(:site).errors[:project_id]
    assert_template 'new'
    assert_response :success
  end

  test "should show site" do
    get :show, id: @site
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @site
    assert_response :success
  end

  test "should update site" do
    put :update, id: @site, site: { description: 'First Site on Project One', emails: 'email@example.com, email2@example.com', name: 'Site One', project_id: @site.project_id, prefix: 'Prefix' }
    assert_redirected_to site_path(assigns(:site))
  end

  test "should destroy site" do
    assert_difference('Site.current.count', -1) do
      delete :destroy, id: @site
    end

    assert_redirected_to sites_path
  end
end
