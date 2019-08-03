# frozen_string_literal: true

require "test_helper"

# Test project team pages.
class TeamControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project = projects(:one)
    @project_editor = users(:project_one_editor)
    @project_viewer = users(:project_one_viewer)
  end

  test "should get team as project editor" do
    login(@project_editor)
    get project_team_url(@project)
    assert_response :success
  end

  test "should get team as project viewer" do
    login(@project_viewer)
    get project_team_url(@project)
    assert_response :success
  end
end
