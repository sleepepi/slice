# frozen_string_literal: true

require "test_helper"

# Test accepting and declining invites
class InvitesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:aes_invited_user)
  end

  test "should get index" do
    login(@user)
    get invites_url
    assert_response :success
  end

  test "should accept unblinded project editor invite" do
    login(@user)
    assert_difference("ProjectUser.where(editor: true, unblinded: true).count") do
      post accept_invite_url(invites(:project_editor_unblinded), format: "js")
    end
    assert_response :success
  end

  test "should decline unblinded project editor invite" do
    login(@user)
    assert_difference("ProjectUser.where(editor: true, unblinded: true).count", 0) do
      post decline_invite_url(invites(:project_editor_unblinded), format: "js")
    end
    assert_response :success
  end

  test "should accept unblinded project viewer invite" do
    login(@user)
    assert_difference("ProjectUser.where(editor: false, unblinded: true).count") do
      post accept_invite_url(invites(:project_viewer_unblinded), format: "js")
    end
    assert_response :success
  end

  test "should decline unblinded project viewer invite" do
    login(@user)
    assert_difference("ProjectUser.where(editor: false, unblinded: true).count", 0) do
      post decline_invite_url(invites(:project_viewer_unblinded), format: "js")
    end
    assert_response :success
  end

  test "should accept blinded project editor invite" do
    login(@user)
    assert_difference("ProjectUser.where(editor: true, unblinded: false).count") do
      post accept_invite_url(invites(:project_editor_blinded), format: "js")
    end
    assert_response :success
  end

  test "should decline blinded project editor invite" do
    login(@user)
    assert_difference("ProjectUser.where(editor: true, unblinded: false).count", 0) do
      post decline_invite_url(invites(:project_editor_blinded), format: "js")
    end
    assert_response :success
  end

  test "should accept blinded project viewer invite" do
    login(@user)
    assert_difference("ProjectUser.where(editor: false, unblinded: false).count") do
      post accept_invite_url(invites(:project_viewer_blinded), format: "js")
    end
    assert_response :success
  end

  test "should decline blinded project viewer invite" do
    login(@user)
    assert_difference("ProjectUser.where(editor: false, unblinded: false).count", 0) do
      post decline_invite_url(invites(:project_viewer_blinded), format: "js")
    end
    assert_response :success
  end

  test "should accept unblinded site editor invite" do
    login(@user)
    assert_difference("SiteUser.where(editor: true, unblinded: true).count") do
      post accept_invite_url(invites(:site_editor_unblinded), format: "js")
    end
    assert_response :success
  end

  test "should decline unblinded site editor invite" do
    login(@user)
    assert_difference("SiteUser.where(editor: true, unblinded: true).count", 0) do
      post decline_invite_url(invites(:site_editor_unblinded), format: "js")
    end
    assert_response :success
  end

  test "should accept unblinded site viewer invite" do
    login(@user)
    assert_difference("SiteUser.where(editor: false, unblinded: true).count") do
      post accept_invite_url(invites(:site_viewer_unblinded), format: "js")
    end
    assert_response :success
  end

  test "should decline unblinded site viewer invite" do
    login(@user)
    assert_difference("SiteUser.where(editor: false, unblinded: true).count", 0) do
      post decline_invite_url(invites(:site_viewer_unblinded), format: "js")
    end
    assert_response :success
  end

  test "should accept blinded site editor invite" do
    login(@user)
    assert_difference("SiteUser.where(editor: true, unblinded: false).count") do
      post accept_invite_url(invites(:site_editor_blinded), format: "js")
    end
    assert_response :success
  end

  test "should decline blinded site editor invite" do
    login(@user)
    assert_difference("SiteUser.where(editor: true, unblinded: false).count", 0) do
      post decline_invite_url(invites(:site_editor_blinded), format: "js")
    end
    assert_response :success
  end

  test "should accept blinded site viewer invite" do
    login(@user)
    assert_difference("SiteUser.where(editor: false, unblinded: false).count") do
      post accept_invite_url(invites(:site_viewer_blinded), format: "js")
    end
    assert_response :success
  end

  test "should decline blinded site viewer invite" do
    login(@user)
    assert_difference("SiteUser.where(editor: false, unblinded: false).count", 0) do
      post decline_invite_url(invites(:site_viewer_blinded), format: "js")
    end
    assert_response :success
  end

  test "should accept ae admin invite" do
    login(@user)
    assert_difference("AeReviewAdmin.count") do
      post accept_invite_url(invites(:ae_admin), format: "js")
    end
    assert_response :success
  end

  test "should decline ae admin invite" do
    login(@user)
    assert_difference("AeReviewAdmin.count", 0) do
      post decline_invite_url(invites(:ae_admin), format: "js")
    end
    assert_response :success
  end

  test "should accept ae team manager invite" do
    login(@user)
    assert_difference("AeTeamMember.where(manager: true).count") do
      post accept_invite_url(invites(:ae_team_manager), format: "js")
    end
    assert_response :success
  end

  test "should decline ae team manager invite" do
    login(@user)
    assert_difference("AeTeamMember.where(manager: true).count", 0) do
      post decline_invite_url(invites(:ae_team_manager), format: "js")
    end
    assert_response :success
  end

  test "should accept ae team principal reviewer invite" do
    login(@user)
    assert_difference("AeTeamMember.where(principal_reviewer: true).count") do
      post accept_invite_url(invites(:ae_team_principal_reviewer), format: "js")
    end
    assert_response :success
  end

  test "should decline ae team principal reviewer invite" do
    login(@user)
    assert_difference("AeTeamMember.where(principal_reviewer: true).count", 0) do
      post decline_invite_url(invites(:ae_team_principal_reviewer), format: "js")
    end
    assert_response :success
  end

  test "should accept ae team reviewer invite" do
    login(@user)
    assert_difference("AeTeamMember.where(reviewer: true).count") do
      post accept_invite_url(invites(:ae_team_reviewer), format: "js")
    end
    assert_response :success
  end

  test "should decline ae team reviewer invite" do
    login(@user)
    assert_difference("AeTeamMember.where(reviewer: true).count", 0) do
      post decline_invite_url(invites(:ae_team_reviewer), format: "js")
    end
    assert_response :success
  end

  test "should accept ae team viewer invite" do
    login(@user)
    assert_difference("AeTeamMember.where(viewer: true).count") do
      post accept_invite_url(invites(:ae_team_viewer), format: "js")
    end
    assert_response :success
  end

  test "should decline ae team viewer invite" do
    login(@user)
    assert_difference("AeTeamMember.where(viewer: true).count", 0) do
      post decline_invite_url(invites(:ae_team_viewer), format: "js")
    end
    assert_response :success
  end
end
