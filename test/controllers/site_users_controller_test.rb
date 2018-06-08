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

  test "should resend site invitation" do
    login(@project_editor)
    post resend_project_site_user_url(@project, @site_user, format: "js")
    assert_template "update"
    assert_response :success
  end

  test "should not resend site invitation with invalid id" do
    login(@project_editor)
    post resend_project_site_user_url(@project, -1, format: "js")
    assert_template nil
    assert_response :success
  end

  test "should get invite for logged in site user" do
    login(users(:two))
    get site_invite_url(site_invite_token: site_users(:invited).invite_token)
    assert_equal session[:site_invite_token], site_users(:invited).invite_token
    assert_redirected_to accept_project_site_users_url(assigns(:site_user).project)
  end

  test "should get invite for public site user" do
    get site_invite_url(site_users(:invited).invite_token)
    assert_equal session[:site_invite_token], site_users(:invited).invite_token
    assert_redirected_to new_user_session_url
  end

  test "should not get invite for logged in site user with invalid token" do
    login(users(:two))
    get site_invite_url("INVALID")
    assert_nil session[:site_invite_token]
    assert_redirected_to root_url
  end

  test "should accept site user" do
    login(users(:two))
    get site_invite_url(site_users(:invited).invite_token)
    assert_redirected_to accept_project_site_users_url(@project)
    get accept_project_site_users_url(@project)
    assert_equal users(:two), assigns(:site_user).user
    assert_equal "You have been successfully added to the project.", flash[:notice]
    assert_redirected_to assigns(:site_user).site.project
  end

  test "should accept existing site user" do
    login(users(:regular))
    get site_invite_url(site_users(:accepted_viewer_invite).invite_token)
    assert_redirected_to accept_project_site_users_url(@project)
    get accept_project_site_users_url(@project)
    assert_equal users(:regular), assigns(:site_user).user
    assert_equal "You have already been added to #{assigns(:site_user).site.name}.", flash[:notice]
    assert_redirected_to assigns(:site_user).site.project
  end

  test "should not accept invalid token for site user" do
    login(users(:regular))
    get site_invite_url("imaninvalidtoken")
    assert_redirected_to root_url
    get accept_project_site_users_url(@project)
    assert_equal "Invalid invitation token.", flash[:alert]
    assert_redirected_to root_url
  end

  test "should not accept site user if invite token is already claimed" do
    login(users(:two))
    get site_invite_url("validintwo")
    assert_redirected_to accept_project_site_users_url(@project)
    get accept_project_site_users_url(@project)
    assert_not_equal users(:two), assigns(:site_user).user
    assert_equal "This invite has already been claimed.", flash[:alert]
    assert_redirected_to root_url
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
