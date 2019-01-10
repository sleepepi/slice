# frozen_string_literal: true

require "test_helper"

class AeModule::AdminsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project = projects(:aes)
    @review_admin = users(:aes_review_admin)
    @adverse_event = ae_adverse_events(:reported)
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

  test "should assign team as review admin" do
    login(@review_admin)
    assert_difference("AeAdverseEventTeam.count") do
      post ae_module_admins_assign_team_url(@project, @adverse_event), params: {
        team_id: ae_teams(:clinical).id
      }
    end
    assert_redirected_to ae_module_adverse_event_url(@project, @adverse_event)
  end

  test "should not assign blank team as review admin" do
    login(@review_admin)
    assert_difference("AeAdverseEventTeam.count", 0) do
      post ae_module_admins_assign_team_url(@project, @adverse_event), params: {
        team_id: ""
      }
    end
    assert_redirected_to ae_module_adverse_event_url(@project, @adverse_event)
  end

  test "should close adverse event as review admin" do
    login(@review_admin)
    assert_difference("AeAdverseEvent.where.not(closed_at: nil).count", 1) do
      post ae_module_admins_close_adverse_event_url(@project, @adverse_event)
    end
    assert_redirected_to ae_module_adverse_event_url(@project, @adverse_event)
  end

  test "should reopen adverse event as review admin" do
    login(@review_admin)
    assert_difference("AeAdverseEvent.where(closed_at: nil).count", 1) do
      post ae_module_admins_reopen_adverse_event_url(@project, ae_adverse_events(:closed))
    end
    assert_redirected_to ae_module_adverse_event_url(@project, ae_adverse_events(:closed))
  end
end
