require 'test_helper'

class SitesControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @project = projects(:one)
    @site = sites(:one)
  end

  test "should get index" do
    get :index, project_id: @project
    assert_response :success
    assert_not_nil assigns(:sites)
  end

  test "should get paginated index" do
    get :index, project_id: @project, format: 'js'
    assert_not_nil assigns(:sites)
    assert_template 'index'
  end

  test "should not get index with invalid project" do
    get :index, project_id: -1
    assert_nil assigns(:sites)
    assert_redirected_to root_path
  end

  test "should get new" do
    get :new, project_id: @project
    assert_response :success
  end

  test "should not get new site with invalid project" do
    get :new, project_id: -1

    assert_nil assigns(:project)
    assert_nil assigns(:site)

    assert_redirected_to root_path
  end

  test "should create site" do
    assert_difference('Site.count') do
      post :create, project_id: @project, site: { name: 'Site New', description: 'New Site on Project One', emails: 'email@example.com', prefix: 'Prefix' }
    end

    assert_redirected_to project_site_path(assigns(:site).project, assigns(:site))
  end

  test "should not create site with blank name" do
    assert_difference('Site.count', 0) do
      post :create, project_id: @project, site: { name: '', description: 'New Site on Project One', emails: 'email@example.com', prefix: 'Prefix' }
    end

    assert_not_nil assigns(:site)
    assert assigns(:site).errors.size > 0
    assert_equal ["can't be blank"], assigns(:site).errors[:name]
    assert_template 'new'
  end

  test "should not create site for invalid project" do
    assert_difference('Site.count', 0) do
      post :create, project_id: -1, site: { name: 'Site New', description: 'New Site on Project One', emails: 'email@example.com', prefix: 'Prefix' }
    end

    assert_nil assigns(:project)
    assert_nil assigns(:site)

    assert_redirected_to root_path
  end

  test "should not create site for site user" do
    login(users(:site_one_viewer))
    assert_difference('Site.count', 0) do
      post :create, project_id: @project, site: { name: 'Site New', description: 'New Site on Project One', emails: 'email@example.com', prefix: 'Prefix' }
    end

    assert_nil assigns(:project)
    assert_nil assigns(:site)

    assert_redirected_to root_path
  end

  test "should show site" do
    get :show, id: @site, project_id: @project
    assert_not_nil assigns(:site)
    assert_response :success
  end

  test "should show site for site user" do
    login(users(:site_one_viewer))
    get :show, id: @site, project_id: @project
    assert_not_nil assigns(:site)
    assert_response :success
  end

  test "should not show invalid site" do
    get :show, id: -1, project_id: @project
    assert_nil assigns(:site)
    assert_redirected_to project_sites_path
  end

  test "should not show site with invalid project" do
    get :show, id: @site, project_id: -1

    assert_nil assigns(:project)
    assert_nil assigns(:site)

    assert_redirected_to root_path
  end

  test "should get edit" do
    get :edit, id: @site, project_id: @project
    assert_response :success
  end

  test "should not get edit for invalid site" do
    get :edit, id: -1, project_id: @project

    assert_not_nil assigns(:project)
    assert_nil assigns(:site)

    assert_redirected_to project_sites_path
  end

  test "should not get edit with invalid project" do
    get :edit, id: @site, project_id: -1

    assert_nil assigns(:project)
    assert_nil assigns(:site)

    assert_redirected_to root_path
  end

  test "should update site" do
    put :update, id: @site, project_id: @project, site: { description: 'First Site on Project One', emails: 'email@example.com, email2@example.com', name: 'Site One', prefix: 'Prefix' }
    assert_redirected_to project_site_path(assigns(:site).project, assigns(:site))
  end

  test "should not update site with blank name" do
    put :update, id: @site, project_id: @project, site: { description: 'First Site on Project One', emails: 'email@example.com, email2@example.com', name: '', prefix: 'Prefix' }
    assert_not_nil assigns(:site)
    assert_equal ["can't be blank"], assigns(:site).errors[:name]
    assert_template 'edit'
  end

  test "should not update invalid site" do
    put :update, id: -1, project_id: @project, site: { description: 'First Site on Project One', emails: 'email@example.com, email2@example.com', name: 'Site One', prefix: 'Prefix' }
    assert_nil assigns(:site)
    assert_redirected_to project_sites_path
  end

  test "should not update with invalid project" do
    put :update, id: @site, project_id: -1, site: { description: 'First Site on Project One', emails: 'email@example.com, email2@example.com', name: 'Site One', prefix: 'Prefix' }

    assert_nil assigns(:project)
    assert_nil assigns(:site)

    assert_redirected_to root_path
  end

  test "should destroy site" do
    assert_difference('Site.current.count', -1) do
      delete :destroy, id: @site, project_id: @project
    end

    assert_not_nil assigns(:site)
    assert_not_nil assigns(:project)

    assert_redirected_to project_sites_path
  end

  test "should not destroy site with invalid project" do
    assert_difference('Site.current.count', 0) do
      delete :destroy, id: @site, project_id: -1
    end

    assert_nil assigns(:project)
    assert_nil assigns(:site)

    assert_redirected_to root_path
  end
end
