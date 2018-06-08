# frozen_string_literal: true

require "test_helper"

# Tests for surveys JSON API.
class Api::V1::SurveysControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project = projects(:api)
    @subject = subjects(:api_one)
    @event = events(:api_event)
    @design = designs(:api_design)
  end

  test "should get show survey" do
    get api_v1_show_survey_path(
      authentication_token: @project.id_and_token, id: @subject,
      event: @event, design: @design, format: "json"
    )
    assert_response :success
  end

  test "should get show survey page" do
    get api_v1_show_survey_page_path(
      authentication_token: @project.id_and_token, id: @subject,
      event: @event, design: @design, page: 1, format: "json"
    )
    assert_response :success
  end

  test "should create survey response" do
    assert_difference("SheetVariable.count") do
      patch api_v1_show_survey_page_path(
        authentication_token: @project.id_and_token, id: @subject,
        event: @event, design: @design, page: 2, response: "42", format: "json"
      )
    end
    assert_response :success
  end

  test "should update survey response" do
    assert_difference("SheetVariable.count", 0) do
      patch api_v1_show_survey_page_path(
        authentication_token: @project.id_and_token, id: @subject,
        event: @event, design: @design, page: 1, response: "2", format: "json"
      )
    end
    assert_response :success
  end
end
