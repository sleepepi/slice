# frozen_string_literal: true

require "test_helper"

# Tests to make sure users can be successfully invited to projects.
class ProjectUsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project = projects(:one)
    @project_editor = users(:project_one_editor)
    @accepted_viewer_invite = project_users(:accepted_viewer_invite)
    @unblinded_member = project_users(:project_one_editor)
    @blinded_member = project_users(:project_one_editor_blinded)
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
