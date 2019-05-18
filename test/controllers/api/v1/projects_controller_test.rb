# frozen_string_literal: true

require "test_helper"

# Test to assure projects can be viewed using authentication token via JSON API.
class Api::V1::ProjectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project = projects(:api)
  end

  test "should get show" do
    get api_v1_project_path(
      authentication_token: @project.id_and_token,
      format: "json"
    )
    assert_response :success
  end

  test "should get survey info" do
    get api_v1_survey_info_path(
      authentication_token: @project.id_and_token,
      event: events(:api_event),
      design: designs(:api_design),
      format: "json"
    )
    assert_response :success
  end

  test "should get subject counts" do
    get api_v1_subject_counts_path(
      authentication_token: @project.id_and_token,
      expressions: ["api_radio is 1"],
      sites: "1",
      format: "json"
    )
    assert_response :success
  end

  test "should get randomizations" do
    get api_v1_randomizations_path(
      authentication_token: @project.id_and_token,
      sites: "1",
      format: "json"
    )
    assert_response :success
  end
end
