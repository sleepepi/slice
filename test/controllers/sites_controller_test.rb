# frozen_string_literal: true

require "test_helper"

# Tests to make sure project editors can edit sites, and that project and site
# members can view sites.
class SitesControllerTest < ActionDispatch::IntegrationTest
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

  test "should get setup" do
    login(@project_editor)
    get setup_project_sites_url(@project)
    assert_response :success
  end

  test "should get add site row" do
    login(@project_editor)
    post add_site_row_project_sites_url(@project, format: "js")
    assert_template "add_site_row"
    assert_response :success
  end

  test "should get create site and keep default site short name" do
    login(users(:regular))
    assert_difference("Site.count", 0) do
      post create_sites_project_sites_url(projects(:default), format: "js"), params: {
        sites: [
          { id: sites(:default_site).id, name: "Default Site" }
        ]
      }
    end
    sites(:default_site).reload
    assert_equal "Default Site", sites(:default_site).short_name
    assert_redirected_to settings_editor_project_url(projects(:default))
  end

  test "should get create site and remove default site short name" do
    login(users(:regular))
    assert_difference("Site.count", 0) do
      post create_sites_project_sites_url(projects(:default), format: "js"), params: {
        sites: [
          { id: sites(:default_site).id, name: "New Name" }
        ]
      }
    end
    sites(:default_site).reload
    assert_equal "NN", sites(:default_site).short_name
    assert_redirected_to settings_editor_project_url(projects(:default))
  end

  test "should get create sites" do
    login(@project_editor)
    assert_difference("Site.count") do
      post create_sites_project_sites_url(@project, format: "js"), params: {
        sites: [
          { id: sites(:one).id, name: sites(:one).name },
          { id: "", name: "New Site" }
        ]
      }
    end
    assert_redirected_to settings_editor_project_url(@project)
  end

  test "should get index" do
    login(@project_editor)
    get project_sites_url(@project)
    assert_response :success
  end

  test "should not get index with invalid project" do
    login(@project_editor)
    get project_sites_url(-1)
    assert_redirected_to root_url
  end

  test "should get new" do
    login(@project_editor)
    get new_project_site_url(@project)
    assert_response :success
  end

  test "should not get new site with invalid project" do
    login(@project_editor)
    get new_project_site_url(-1)
    assert_redirected_to root_url
  end

  test "should create site" do
    login(@project_editor)
    assert_difference("Site.count") do
      post project_sites_url(@project), params: {
        site: site_params.merge(name: "Site New")
      }
    end
    assert_redirected_to [@project, Site.last]
  end

  test "should not create site with blank name" do
    login(@project_editor)
    assert_difference("Site.count", 0) do
      post project_sites_url(@project), params: {
        site: site_params.merge(name: "")
      }
    end
    assert_equal ["can't be blank"], assigns(:site).errors[:name]
    assert_template "new"
    assert_response :success
  end

  test "should not create site for invalid project" do
    login(@project_editor)
    assert_difference("Site.count", 0) do
      post project_sites_url(-1), params: {
        site: site_params.merge(name: "Site New")
      }
    end
    assert_redirected_to root_url
  end

  test "should not create site for site viewer" do
    login(@site_viewer)
    assert_difference("Site.count", 0) do
      post project_sites_url(@project), params: {
        site: site_params.merge(name: "Site New")
      }
    end
    assert_redirected_to root_url
  end

  test "should show site" do
    login(@project_editor)
    get project_site_url(@project, @site)
    assert_response :success
  end

  test "should show site for site viewer" do
    login(@site_viewer)
    get project_site_url(@project, @site)
    assert_response :success
  end

  test "should not show invalid site" do
    login(@project_editor)
    get project_site_url(@project, -1)
    assert_redirected_to project_sites_url(@project)
  end

  test "should not show site with invalid project" do
    login(@project_editor)
    get project_site_url(-1, @site)
    assert_redirected_to root_url
  end

  test "should get edit" do
    login(@project_editor)
    get edit_project_site_url(@project, @site)
    assert_response :success
  end

  test "should not get edit for invalid site" do
    login(@project_editor)
    get edit_project_site_url(@project, -1)
    assert_redirected_to project_sites_url(@project)
  end

  test "should not get edit with invalid project" do
    login(@project_editor)
    get edit_project_site_url(-1, @site)
    assert_redirected_to root_url
  end

  test "should update site" do
    login(@project_editor)
    patch project_site_url(@project, @site), params: { site: site_params }
    assert_redirected_to project_site_url(@project, @site)
  end

  test "should not update site with blank name" do
    login(@project_editor)
    patch project_site_url(@project, @site), params: {
      site: site_params.merge(name: "")
    }
    assert_equal ["can't be blank"], assigns(:site).errors[:name]
    assert_template "edit"
    assert_response :success
  end

  test "should not update invalid site" do
    login(@project_editor)
    patch project_site_url(@project, -1), params: { site: site_params }
    assert_redirected_to project_sites_url(@project)
  end

  test "should not update with invalid project" do
    login(@project_editor)
    patch project_site_url(-1, @site), params: { site: site_params }
    assert_redirected_to root_url
  end

  test "should destroy site" do
    login(@project_editor)
    assert_difference("Subject.current.count", -3) do
      assert_difference("Site.current.count", -1) do
        delete project_site_url(@project, @site)
      end
    end
    assert_redirected_to project_sites_url(@project)
  end

  test "should not destroy site with invalid project" do
    login(@project_editor)
    assert_difference("Site.current.count", 0) do
      delete project_site_url(-1, @site)
    end
    assert_redirected_to root_url
  end
end
