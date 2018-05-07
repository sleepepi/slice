# frozen_string_literal: true

require "test_helper"

# Test to assure projects can be viewed using authentication token via JSON API.
class Api::V1::ProjectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project = projects(:api)
  end

  test "should get show" do
    get api_v1_project_path(authentication_token: @project.id_and_token, format: "json")
    assert_not_nil assigns(:project)
    assert_response :success
  end

  test "should get survey info" do
    get api_v1_survey_info_path(authentication_token: @project.id_and_token, event: events(:api_event), design: designs(:api_design), format: "json")
    assert_not_nil assigns(:event)
    assert_not_nil assigns(:design)
    assert_response :success
  end
end
