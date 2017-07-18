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
end
