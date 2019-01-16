# frozen_string_literal: true

require "test_helper"

# Tests to assure that project editors can manage adverse event team pathways.
class Editor::AePathwaysControllerTest < ActionDispatch::IntegrationTest
  setup do
    @editor = users(:aes_project_editor)
    @project = projects(:aes)
    @team = ae_teams(:clinical)
    @pathway = ae_team_pathways(:mild)
  end

  def pathway_params
    {
      name: "Pathway"
    }
  end

  test "should get index" do
    login(@editor)
    get editor_project_ae_team_ae_pathways_path(@project, @team)
    assert_response :success
  end

  test "should get new" do
    login(@editor)
    get new_editor_project_ae_team_ae_pathway_path(@project, @team)
    assert_response :success
  end

  test "should create pathway" do
    login(@editor)
    assert_difference("AeTeamPathway.count") do
      post editor_project_ae_team_ae_pathways_path(@project, @team), params: {
        ae_team_pathway: pathway_params
      }
    end
    assert_redirected_to editor_project_ae_team_ae_pathway_path(
      @project, @team, AeTeamPathway.last
    )
  end

  test "should not create pathway without name" do
    login(@editor)
    assert_difference("AeTeamPathway.count", 0) do
      post editor_project_ae_team_ae_pathways_path(@project, @team), params: {
        ae_team_pathway: pathway_params.merge(name: "")
      }
    end
    assert_template "new"
    assert_response :success
  end

  test "should show pathway" do
    login(@editor)
    get editor_project_ae_team_ae_pathway_path(@project, @team, @pathway)
    assert_response :success
  end

  test "should get edit" do
    login(@editor)
    get edit_editor_project_ae_team_ae_pathway_path(
      @project, @team, @pathway
    )
    assert_response :success
  end

  test "should update pathway" do
    login(@editor)
    patch editor_project_ae_team_ae_pathway_path(
      @project, @team, @pathway
    ), params: { ae_team_pathway: pathway_params }
    assert_redirected_to editor_project_ae_team_ae_pathway_path(
      @project, @team, @pathway
    )
  end

  test "should not update pathway without name" do
    login(@editor)
    patch editor_project_ae_team_ae_pathway_path(
      @project, @team, @pathway
    ), params: { ae_team_pathway: pathway_params.merge(name: "") }
    assert_template "edit"
    assert_response :success
  end

  test "should destroy pathway" do
    login(@editor)
    assert_difference("AeTeamPathway.current.count", -1) do
      delete editor_project_ae_team_ae_pathway_path(
        @project, @team, @pathway
      )
    end
    assert_redirected_to editor_project_ae_team_ae_pathways_path(
      @project, @team
    )
  end
end
