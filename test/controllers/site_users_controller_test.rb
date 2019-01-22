# frozen_string_literal: true

require "test_helper"

# Tests to make sure users can be successfully invited to project sites.
class SiteUsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project = projects(:one)
    @project_editor = users(:project_one_editor)
    @site_user = site_users(:one)
    @unblinded_member = site_users(:site_editor)
    @blinded_member = site_users(:site_editor_blinded)
  end

  test "should set site user as blinded" do
    login(@project_editor)
    assert_difference("SiteUser.where(unblinded: true).count", -1) do
      patch project_site_user_url(@project, @unblinded_member, format: "js"), params: {
        unblinded: "0"
      }
    end
    assert_template "update"
    assert_response :success
  end

  test "should set site user as unblinded" do
    login(@project_editor)
    assert_difference("SiteUser.where(unblinded: false).count", -1) do
      patch project_site_user_url(@project, @blinded_member, format: "js"), params: {
        unblinded: "1"
      }
    end
    assert_template "update"
    assert_response :success
  end

  test "should destroy site_user" do
    login(users(:regular))
    assert_difference("SiteUser.count", -1) do
      delete project_site_user_url(@project, @site_user, format: "js")
    end
    assert_template "projects/members"
    assert_response :success
  end

  test "should not destroy site_user as a site user" do
    login(users(:site_one_viewer))
    assert_difference("SiteUser.count", 0) do
      delete project_site_user_url(@project, @site_user, format: "js")
    end
    assert_response :success
  end

  test "should destroy site_user if signed in user is the selected site user" do
    login(users(:site_one_viewer))
    assert_difference("SiteUser.count", -1) do
      delete project_site_user_url(@project, site_users(:site_viewer), format: "js")
    end
    assert_template "projects/members"
    assert_response :success
  end
end
