# frozen_string_literal: true

require "test_helper"

class AeModule::ManagersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project = projects(:aes)
    @team_manager = users(:aes_team_manager)
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

  test "should get determine_pathway" do
    login(@team_manager)
    get ae_module_managers_determine_pathway_url(@project)
    assert_response :success
  end

  test "should get pathway_assigned" do
    login(@team_manager)
    get ae_module_managers_pathway_assigned_url(@project)
    assert_response :success
  end

  test "should get final_review" do
    login(@team_manager)
    get ae_module_managers_final_review_url(@project)
    assert_response :success
  end

  test "should get final_review_submitted" do
    login(@team_manager)
    get ae_module_managers_final_review_submitted_url(@project)
    assert_response :success
  end
end
