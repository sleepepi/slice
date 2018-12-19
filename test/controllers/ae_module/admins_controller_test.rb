# frozen_string_literal: true

require "test_helper"

class AeModule::AdminsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project = projects(:aes)
    @review_admin = users(:aes_review_admin)
    @adverse_event = ae_adverse_events(:reported)
  end

  def ae_adverse_event_info_request_params
    {
      comment: "Please fill in missing details in report form."
    }
  end

  test "should get inbox as review admin" do
    login(@review_admin)
    get ae_module_adverse_events_url(@project)
    assert_response :success
  end

  test "should get adverse event as review admin" do
    login(@review_admin)
    get ae_module_adverse_event_url(@project, @adverse_event)
    assert_response :success
  end

  test "should get request additional details as review admin" do
    login(@review_admin)
    get ae_module_admins_request_additional_details_url(@project, @adverse_event)
    assert_response :success
  end

  test "should create info request as review admin" do
    login(@review_admin)
    assert_difference("AeAdverseEventInfoRequest.count") do
      post ae_module_admins_submit_request_additional_details_url(@project, @adverse_event), params: {
        ae_adverse_event_info_request: ae_adverse_event_info_request_params
      }
    end
    assert_redirected_to ae_module_adverse_event_url(@project, @adverse_event)
  end

  test "should not create info request without comment as review admin" do
    login(@review_admin)
    assert_difference("AeAdverseEventInfoRequest.count", 0) do
      post ae_module_admins_submit_request_additional_details_url(@project, @adverse_event), params: {
        ae_adverse_event_info_request: ae_adverse_event_info_request_params.merge(comment: "")
      }
    end
    assert_response :success
  end

  test "should assign team as review admin" do
    login(@review_admin)
    assert_difference("AeAdverseEventReviewTeam.count") do
      post ae_module_admins_assign_team_url(@project, @adverse_event), params: {
        review_team_id: ae_review_teams(:clinical).id
      }
    end
    assert_redirected_to ae_module_adverse_event_url(@project, @adverse_event)
  end

  test "should not assign blank team as review admin" do
    login(@review_admin)
    assert_difference("AeAdverseEventReviewTeam.count", 0) do
      post ae_module_admins_assign_team_url(@project, @adverse_event), params: {
        review_team_id: ""
      }
    end
    assert_redirected_to ae_module_adverse_event_url(@project, @adverse_event)
  end
end
