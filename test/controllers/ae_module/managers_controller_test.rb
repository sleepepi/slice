# frozen_string_literal: true

require "test_helper"

class AeModule::ManagersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project = projects(:aes)
    @team_manager = users(:aes_team_manager)
    @team = ae_teams(:clinical)
    @adverse_event = ae_adverse_events(:closed)
    # @pathway = ae_team_pathways(:heart_failure)
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

  test "should assign reviewers" do
    login(@team_manager)
    assert_difference("AeAdverseEventReviewerAssignment.count", 2) do
      post ae_module_managers_assign_reviewers_url(@project, @team, ae_adverse_events(:teamset)), params: {
        principal_reviewer_id: users(:aes_team_principal_reviewer).id,
        reviewer_ids: {
          "0" => 1,
          users(:aes_team_reviewer).id.to_s => 1
        },
        pathway_ids: {
          "0" => 1,
          ae_team_pathways(:heart_failure).id.to_s => 1
        }
      }
    end
    assert_redirected_to ae_module_adverse_event_url(@project, ae_adverse_events(:teamset))
  end

  test "should mark team review as complete as manager" do
    login(@team_manager)
    assert_difference("AeAdverseEventTeam.where.not(team_review_completed_at: nil).count", 1) do
      post ae_module_managers_team_review_completed_url(@project, @team, ae_adverse_events(:pathdone))
    end
    assert_redirected_to ae_module_adverse_event_url(@project, ae_adverse_events(:pathdone))
  end

  test "should mark team review as incomplete as manager" do
    login(@team_manager)
    assert_difference("AeAdverseEventTeam.where(team_review_completed_at: nil).count", 1) do
      post ae_module_managers_team_review_uncompleted_url(@project, @team, ae_adverse_events(:teamdone))
    end
    assert_redirected_to ae_module_adverse_event_url(@project, ae_adverse_events(:teamdone))
  end
end
