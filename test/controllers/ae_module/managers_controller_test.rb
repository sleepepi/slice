# frozen_string_literal: true

require "test_helper"

class AeModule::ManagersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project = projects(:aes)
    @team_manager = users(:aes_team_manager)
    @team = ae_review_teams(:clinical)
    @adverse_event = ae_adverse_events(:closed)
    @pathway = ae_team_pathways(:heart_failure)
  end

  test "should get dashboard" do
    login(@team_manager)
    get ae_module_managers_dashboard_url(@project)
    assert_response :success
  end

  test "should get inbox" do
    login(@team_manager)
    get ae_module_managers_inbox_url(@project)
    assert_response :success
  end

  test "should get determine pathway" do
    login(@team_manager)
    get ae_module_managers_determine_pathway_url(@project, @team, @adverse_event)
    assert_response :success
  end

  test "should get pathway assignments" do
    login(@team_manager)
    get ae_module_managers_pathway_assignments_url(@project, @team, @adverse_event, @pathway)
    assert_response :success
  end

  test "should get final review" do
    login(@team_manager)
    get ae_module_managers_final_review_url(@project, @team, @adverse_event, @pathway)
    assert_response :success
  end

  test "should get final review submitted" do
    login(@team_manager)
    get ae_module_managers_final_review_submitted_url(@project, @team, @adverse_event, @pathway)
    assert_response :success
  end
end
