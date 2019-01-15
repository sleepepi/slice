# frozen_string_literal: true

require "test_helper"

# Tests to assure that project editors can create and update project teams.
class Editor::AeTeamsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @editor = users(:aes_project_editor)
    @project = projects(:aes)
    @team = ae_teams(:clinical)
  end

  def team_params
    {
      name: "Team Three",
      slug: "team-three",
      short_name: "Three"
    }
  end

  test "should get index" do
    login(@editor)
    get editor_project_ae_teams_path(@project)
    assert_response :success
  end

  test "should get new" do
    login(@editor)
    get new_editor_project_ae_team_path(@project)
    assert_response :success
  end

  test "should create team" do
    login(@editor)
    assert_difference("AeTeam.count") do
      post editor_project_ae_teams_path(@project), params: {
        ae_team: team_params
      }
    end
    assert_redirected_to editor_project_ae_team_path(@project, AeTeam.last)
  end

  test "should not create team with blank name" do
    login(@editor)
    assert_difference("AeTeam.count", 0) do
      post editor_project_ae_teams_path(@project), params: {
        ae_team: team_params.merge(name: "")
      }
    end
    assert_template "new"
    assert_response :success
  end

  test "should show team" do
    login(@editor)
    get editor_project_ae_team_path(@project, @team)
    assert_response :success
  end

  test "should get edit" do
    login(@editor)
    get edit_editor_project_ae_team_path(@project, @team)
    assert_response :success
  end

  test "should update team" do
    login(@editor)
    patch editor_project_ae_team_path(@project, @team), params: {
      ae_team: team_params.merge(slug: "slug-update")
    }
    assert_redirected_to editor_project_ae_team_path(@project, "slug-update")
  end

  test "should update team with ajax" do
    login(@editor)
    patch editor_project_ae_team_path(@project, @team, format: "js"), params: {
      ae_team: team_params
    }
    assert_template "update"
    assert_response :success
  end

  test "should not update team with blank name" do
    login(@editor)
    patch editor_project_ae_team_path(@project, @team), params: {
      ae_team: team_params.merge(name: "")
    }
    assert_template "edit"
    assert_response :success
  end

  test "should destroy team" do
    login(@editor)
    assert_difference("AeTeam.current.count", -1) do
      delete editor_project_ae_team_path(@project, @team)
    end
    assert_redirected_to editor_project_ae_teams_path(@project)
  end

  test "should destroy team with ajax" do
    login(@editor)
    assert_difference("AeTeam.current.count", -1) do
      delete editor_project_ae_team_path(@project, @team, format: "js")
    end
    assert_template "destroy"
    assert_response :success
  end
end
