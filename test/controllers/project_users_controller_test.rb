# frozen_string_literal: true

require "test_helper"

# Tests to make sure users can be successfully invited to projects.
class ProjectUsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project = projects(:one)
    @project_editor = users(:project_one_editor)
    @pending_editor_invite = project_users(:pending_editor_invite)
    @accepted_viewer_invite = project_users(:accepted_viewer_invite)
    @unblinded_member = project_users(:project_one_editor)
    @blinded_member = project_users(:project_one_editor_blinded)
  end

  test "should resend project invitation" do
    login(@project_editor)
    post resend_project_user_url(@pending_editor_invite, format: "js")
    assert_template "update"
    assert_response :success
  end

  test "should not resend project invitation with invalid id" do
    login(@project_editor)
    post resend_project_user_url(-1, format: "js")
    assert_template nil
    assert_response :success
  end

  test "should get invite for logged in user" do
    login(users(:two))
    get invite_url(invite_token: @pending_editor_invite.invite_token)
    assert_equal session[:invite_token], @pending_editor_invite.invite_token
    assert_redirected_to accept_project_users_url
  end

  test "should get invite for public user" do
    get invite_url(invite_token: @pending_editor_invite.invite_token)
    assert_equal session[:invite_token], @pending_editor_invite.invite_token
    assert_redirected_to new_user_session_url
  end

  test "should accept project user" do
    login(users(:two))
    get invite_url(@pending_editor_invite.invite_token)
    assert_redirected_to accept_project_users_url
    get accept_project_users_url
    assert_equal users(:two), assigns(:project_user).user
    assert_equal(
      "You have been successfully added to the project.",
      flash[:notice]
    )
    assert_redirected_to assigns(:project_user).project
  end

  test "should accept existing project user" do
    login(users(:regular))
    get invite_url(project_users(:accepted_viewer_invite).invite_token)
    assert_redirected_to accept_project_users_url
    get accept_project_users_url
    assert_equal users(:regular), assigns(:project_user).user
    assert_equal(
      "You have already been added to #{assigns(:project_user).project.name}.",
      flash[:notice]
    )
    assert_redirected_to assigns(:project_user).project
  end

  test "should not accept invalid token for project user" do
    login(users(:regular))
    get invite_url("imaninvalidtoken")
    assert_redirected_to accept_project_users_url
    get accept_project_users_url
    assert_equal "Invalid invitation token.", flash[:alert]
    assert_redirected_to root_url
  end

  test "should not accept project user if invite token is already claimed" do
    login(users(:two))
    get invite_url("accepted_viewer_invite")
    assert_redirected_to accept_project_users_url
    get accept_project_users_url
    assert_not_equal users(:two), assigns(:project_user).user
    assert_equal "This invite has already been claimed.", flash[:alert]
    assert_redirected_to root_url
  end

  test "should set project user as blinded" do
    login(@project_editor)
    assert_difference("ProjectUser.where(unblinded: true).count", -1) do
      patch project_user_url(@unblinded_member, format: "js"), params: {
        project_id: @project.id,
        unblinded: "0"
      }
    end
    assert_template "update"
    assert_response :success
  end

  test "should set project user as unblinded" do
    login(@project_editor)
    assert_difference("ProjectUser.where(unblinded: false).count", -1) do
      patch project_user_url(@blinded_member, format: "js"), params: {
        project_id: @project.id,
        unblinded: "1"
      }
    end
    assert_template "update"
    assert_response :success
  end

  test "should destroy project user" do
    login(users(:regular))
    assert_difference("ProjectUser.count", -1) do
      delete project_user_url(@accepted_viewer_invite, format: "js")
    end
    assert_template "projects/members"
  end

  test "should allow viewer to remove self from project" do
    login(users(:project_one_viewer))
    assert_difference("ProjectUser.count", -1) do
      delete project_user_url(project_users(:project_one_viewer), format: "js")
    end
    assert_template "projects/members"
  end

  test "should not destroy project user with invalid id" do
    login(users(:regular))
    assert_difference("ProjectUser.count", 0) do
      delete project_user_url(-1, format: "js")
    end
    assert_response :success
  end
end
