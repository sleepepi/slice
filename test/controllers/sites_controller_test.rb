# frozen_string_literal: true

require 'test_helper'

# Tests to make sure project editors can edit sites, and that project and site
# members can view sites.
class SitesControllerTest < ActionController::TestCase
  setup do
    @project = projects(:one)
    @site = sites(:one)
    @project_editor = users(:project_one_editor)
    @site_viewer = users(:site_one_viewer)
  end

  def site_params
    {
      name: @site.name,
      short_name: @site.short_name,
      description: @site.description,
      subject_code_format: @site.subject_code_format
    }
  end

  test 'should get setup' do
    login(@project_editor)
    get :setup, params: { project_id: @project }
    assert_response :success
  end

  test 'should get add site row' do
    login(@project_editor)
    post :add_site_row, params: { project_id: @project }, format: 'js'
    assert_template 'add_site_row'
    assert_response :success
  end

  test 'should get create sites' do
    login(@project_editor)
    assert_difference('Site.count') do
      post :create_sites, params: {
        project_id: @project,
        sites: [
          { id: sites(:one).id, name: sites(:one).name },
          { id: '', name: 'New Site' }
        ]
      }, format: 'js'
    end
    assert_redirected_to invite_editor_project_path(@project)
  end

  test 'should get index' do
    login(@project_editor)
    get :index, params: { project_id: @project }
    assert_response :success
  end

  test 'should get paginated index' do
    login(@project_editor)
    get :index, params: { project_id: @project }, format: 'js'
    assert_template 'index'
    assert_response :success
  end

  test 'should not get index with invalid project' do
    login(@project_editor)
    get :index, params: { project_id: -1 }
    assert_redirected_to root_path
  end

  test 'should get new' do
    login(@project_editor)
    get :new, params: { project_id: @project }
    assert_response :success
  end

  test 'should not get new site with invalid project' do
    login(@project_editor)
    get :new, params: { project_id: -1 }
    assert_redirected_to root_path
  end

  test 'should create site' do
    login(@project_editor)
    assert_difference('Site.count') do
      post :create, params: {
        project_id: @project, site: site_params.merge(name: 'Site New')
      }
    end
    assert_redirected_to [@project, Site.last]
  end

  test 'should not create site with blank name' do
    login(@project_editor)
    assert_difference('Site.count', 0) do
      post :create, params: {
        project_id: @project, site: site_params.merge(name: '')
      }
    end
    assert_not_nil assigns(:site)
    assert assigns(:site).errors.size > 0
    assert_equal ["can't be blank"], assigns(:site).errors[:name]
    assert_template 'new'
    assert_response :success
  end

  test 'should not create site for invalid project' do
    login(@project_editor)
    assert_difference('Site.count', 0) do
      post :create, params: {
        project_id: -1, site: site_params.merge(name: 'Site New')
      }
    end
    assert_redirected_to root_path
  end

  test 'should not create site for site viewer' do
    login(@site_viewer)
    assert_difference('Site.count', 0) do
      post :create, params: {
        project_id: @project, site: site_params.merge(name: 'Site New')
      }
    end
    assert_redirected_to root_path
  end

  test 'should show site' do
    login(@project_editor)
    get :show, params: { project_id: @project, id: @site }
    assert_response :success
  end

  test 'should show site for site viewer' do
    login(@site_viewer)
    get :show, params: { project_id: @project, id: @site }
    assert_response :success
  end

  test 'should not show invalid site' do
    login(@project_editor)
    get :show, params: { project_id: @project, id: -1 }
    assert_redirected_to project_sites_path
  end

  test 'should not show site with invalid project' do
    login(@project_editor)
    get :show, params: { project_id: -1, id: @site }
    assert_redirected_to root_path
  end

  test 'should get edit' do
    login(@project_editor)
    get :edit, params: { project_id: @project, id: @site }
    assert_response :success
  end

  test 'should not get edit for invalid site' do
    login(@project_editor)
    get :edit, params: { project_id: @project, id: -1 }
    assert_redirected_to project_sites_path(@project)
  end

  test 'should not get edit with invalid project' do
    login(@project_editor)
    get :edit, params: { project_id: -1, id: @site }
    assert_nil assigns(:project)
    assert_nil assigns(:site)
    assert_redirected_to root_path
  end

  test 'should update site' do
    login(@project_editor)
    patch :update, params: {
      project_id: @project, id: @site, site: site_params
    }
    assert_redirected_to project_site_path(@project, @site)
  end

  test 'should not update site with blank name' do
    login(@project_editor)
    patch :update, params: {
      project_id: @project, id: @site, site: site_params.merge(name: '')
    }
    assert_not_nil assigns(:site)
    assert_equal ["can't be blank"], assigns(:site).errors[:name]
    assert_template 'edit'
    assert_response :success
  end

  test 'should not update invalid site' do
    login(@project_editor)
    patch :update, params: { project_id: @project, id: -1, site: site_params }
    assert_redirected_to project_sites_path(@project)
  end

  test 'should not update with invalid project' do
    login(@project_editor)
    patch :update, params: { project_id: -1, id: @site, site: site_params }
    assert_redirected_to root_path
  end

  test 'should destroy site' do
    login(@project_editor)
    assert_difference('Subject.current.count', -3) do
      assert_difference('Site.current.count', -1) do
        delete :destroy, params: { project_id: @project, id: @site }
      end
    end
    assert_redirected_to project_sites_path(@project)
  end

  test 'should not destroy site with invalid project' do
    login(@project_editor)
    assert_difference('Site.current.count', 0) do
      delete :destroy, params: { project_id: -1, id: @site }
    end
    assert_redirected_to root_path
  end
end
