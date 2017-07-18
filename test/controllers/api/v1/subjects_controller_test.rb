# frozen_string_literal: true

require "test_helper"

# Tests for subjects JSON API.
class Api::V1::SubjectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project = projects(:api)
    @subject = subjects(:api_one)
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
end
