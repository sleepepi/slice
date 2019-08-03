# frozen_string_literal: true

require "test_helper"

# Test project team pages.
class TeamControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project = projects(:one)
    @site = sites(:one)
    @project_editor = users(:project_one_editor)
    @project_viewer = users(:project_one_viewer)
  end

  test "should get team as project editor" do
    login(@project_editor)
    get project_team_url(@project)
    assert_response :success
  end

  test "should get team as project viewer" do
    login(@project_viewer)
    get project_team_url(@project)
    assert_response :success
  end

  test "should get team page filtered by site" do
    login(@project_editor)
    get project_team_url(@project, site_id: @site)
    assert_response :success
  end

  test "should get team page filtered by project owner" do
    login(@project_editor)
    get project_team_url(@project, role: "project_owner")
    assert_response :success
  end

  test "should get team page filtered by project editor unblinded" do
    login(@project_editor)
    get project_team_url(@project, role: "project_editor_unblinded")
    assert_response :success
  end

  test "should get team page filtered by project viewer unblinded" do
    login(@project_editor)
    get project_team_url(@project, role: "project_viewer_unblinded")
    assert_response :success
  end

  test "should get team page filtered by project editor blinded" do
    login(@project_editor)
    get project_team_url(@project, role: "project_editor_blinded")
    assert_response :success
  end

  test "should get team page filtered by project viewer blinded" do
    login(@project_editor)
    get project_team_url(@project, role: "project_viewer_blinded")
    assert_response :success
  end

  test "should get team page filtered by site editor unblinded" do
    login(@project_editor)
    get project_team_url(@project, role: "site_editor_unblinded")
    assert_response :success
  end

  test "should get team page filtered by site viewer unblinded" do
    login(@project_editor)
    get project_team_url(@project, role: "site_viewer_unblinded")
    assert_response :success
  end

  test "should get team page filtered by site editor blinded" do
    login(@project_editor)
    get project_team_url(@project, role: "site_editor_blinded")
    assert_response :success
  end

  test "should get team page filtered by site viewer blinded" do
    login(@project_editor)
    get project_team_url(@project, role: "site_viewer_blinded")
    assert_response :success
  end

  test "should get team page filtered by ae admin" do
    login(users(:aes_project_editor))
    get project_team_url(projects(:aes), role: "ae_admin")
    assert_response :success
  end

  test "should get team page filtered by ae team manager" do
    login(users(:aes_project_editor))
    get project_team_url(projects(:aes), role: "ae_team_manager")
    assert_response :success
  end

  test "should get team page filtered by ae team principal reviewer" do
    login(users(:aes_project_editor))
    get project_team_url(projects(:aes), role: "ae_team_principal_reviewer")
    assert_response :success
  end

  test "should get team page filtered by ae team reviewer" do
    login(users(:aes_project_editor))
    get project_team_url(projects(:aes), role: "ae_team_reviewer")
    assert_response :success
  end

  test "should get team page filtered by ae team viewer" do
    login(users(:aes_project_editor))
    get project_team_url(projects(:aes), role: "ae_team_viewer")
    assert_response :success
  end

  test "should get team page filtered by ae team" do
    login(users(:aes_project_editor))
    get project_team_url(projects(:aes), ae_team: ae_teams(:clinical))
    assert_response :success
  end
end
