# frozen_string_literal: true

require "test_helper"

# Test project editors managing invitations
class Editor::InvitesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @editor = users(:aes_project_editor)
    @project = projects(:aes)
    @site = sites(:aes_site)
    @team = ae_teams(:clinical)
    @invite = invites(:site_editor_unblinded)
  end

  def invite_params
    {
      email: "invite@example.com",
      subgroup_type: "Site",
      subgroup_id: @site.id,
      role_level: "site",
      site_id: @site.id,
      team_id: "",
      role: "site_editor_unblinded"
    }
  end

  test "should get index" do
    login(@editor)
    get editor_project_invites_url(@project)
    assert_response :success
  end

  test "should get new" do
    login(@editor)
    get new_editor_project_invite_url(@project)
    assert_response :success
  end

  test "should create invite" do
    login(@editor)
    assert_difference("Invite.count") do
      post editor_project_invites_url(@project), params: {
        invite: invite_params.merge(email: "newinvite@example.com")
      }
    end
    assert_redirected_to editor_project_invites_url(@project)
  end

  test "should not create invite without email" do
    login(@editor)
    assert_difference("Invite.count", 0) do
      post editor_project_invites_url(@project), params: {
        invite: invite_params.merge(email: "")
      }
    end
    assert_template "new"
    assert_response :success
  end

  test "should not create invite with site role assigned to team" do
    login(@editor)
    assert_difference("Invite.count", 0) do
      post editor_project_invites_url(@project), params: {
        invite: invite_params.merge(
          role: "site_editor_unblinded",
          subgroup_type: "AeTeam",
          subgroup_id: ae_teams(:clinical).id
        )
      }
    end
    assert_template "new"
    assert_response :success
  end

  test "should not create invite with team role assigned to site" do
    login(@editor)
    assert_difference("Invite.count", 0) do
      post editor_project_invites_url(@project), params: {
        invite: invite_params.merge(
          role: "ae_team_manager",
          subgroup_type: "Site",
          subgroup_id: @site.id
        )
      }
    end
    assert_template "new"
    assert_response :success
  end

  test "should show invite for project editor" do
    login(@editor)
    get editor_project_invite_url(@project, invites(:project_editor_unblinded))
    assert_response :success
  end

  test "should show invite for site editor" do
    login(@editor)
    get editor_project_invite_url(@project, invites(:site_editor_unblinded))
    assert_response :success
  end

  test "should show invite for team reviewer" do
    login(@editor)
    get editor_project_invite_url(@project, invites(:ae_team_reviewer))
    assert_response :success
  end

  test "should get edit" do
    login(@editor)
    get edit_editor_project_invite_url(@project, @invite)
    assert_response :success
  end

  test "should update invite" do
    login(@editor)
    patch editor_project_invite_url(@project, @invite), params: {
      invite: invite_params.merge(role: "site_editor_unblinded")
    }
    assert_redirected_to editor_project_invites_url(@project)
  end

  test "should not update invite without role" do
    login(@editor)
    patch editor_project_invite_url(@project, @invite), params: {
      invite: invite_params.merge(role: "")
    }
    assert_template "edit"
    assert_response :success
  end

  test "should destroy invite" do
    login(@editor)
    assert_difference("Invite.count", -1) do
      delete editor_project_invite_url(@project, @invite)
    end
    assert_redirected_to editor_project_invites_url(@project)
  end
end
