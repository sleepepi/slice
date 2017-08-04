# frozen_string_literal: true

require "test_helper"

# Tests for subjects JSON API.
class Api::V1::SubjectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project = projects(:api)
    @subject = subjects(:api_one)
  end

  test "should get index" do
    get api_v1_subjects_path(authentication_token: @project.id_and_token, format: "json")
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:subjects)
    assert_response :success
  end

  test "should get show" do
    get api_v1_subject_path(authentication_token: @project.id_and_token, id: @subject, format: "json")
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:subject)
    assert_response :success
  end

  test "should get events" do
    get api_v1_subject_events_path(authentication_token: @project.id_and_token, id: @subject, format: "json")
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:subject)
    assert_response :success
  end

  test "should create subject" do
    assert_difference("Subject.count") do
      post api_v1_create_subject_path(
        authentication_token: @project.id_and_token,
        subject: {
          subject_code: "S00001",
          site_id: sites(:api_site)
        },
        format: "json"
      )
    end
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:subject)
    assert_response :success
  end

  test "should not create subject without subject code" do
    assert_difference("Subject.count", 0) do
      post api_v1_create_subject_path(
        authentication_token: @project.id_and_token,
        subject: {
          subject_code: "",
          site_id: sites(:api_site)
        },
        format: "json"
      )
    end
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:subject)
    assert_response :unprocessable_entity
  end

  test "should create subject event" do
    assert_difference("SubjectEvent.count") do
      post api_v1_create_event_path(
        authentication_token: @project.id_and_token,
        id: @subject,
        event_id: events(:api_event),
        format: "json"
      )
    end
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:subject)
    assert_not_nil assigns(:event)
    assert_not_nil assigns(:subject_event)
    assert_response :success
  end

  test "should create not subject event without event" do
    assert_difference("SubjectEvent.count", 0) do
      post api_v1_create_event_path(
        authentication_token: @project.id_and_token,
        id: @subject,
        event_id: nil,
        format: "json"
      )
    end
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:subject)
    assert_nil assigns(:event)
    assert_not_nil assigns(:subject_event)
    assert_response :unprocessable_entity
  end

  test "should create subject sheet" do
    assert_difference("Sheet.count") do
      post api_v1_create_sheet_path(
        authentication_token: @project.id_and_token,
        id: @subject,
        subject_event_id: subject_events(:api_one_api_event),
        design_id: designs(:api_design_two).id,
        format: "json"
      )
    end
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:subject)
    assert_not_nil assigns(:sheet)
    assert_response :success
  end

  test "should not create duplicate subject sheet" do
    assert_difference("Sheet.count", 0) do
      post api_v1_create_sheet_path(
        authentication_token: @project.id_and_token,
        id: @subject,
        subject_event_id: subject_events(:api_one_api_event),
        design_id: designs(:api_design).id,
        format: "json"
      )
    end
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:subject)
    assert_not_nil assigns(:sheet)
    assert_response :success
  end
end
