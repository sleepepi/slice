# frozen_string_literal: true

require "test_helper"

class AeModule::ReviewersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project = projects(:aes)
    @reviewer = users(:aes_team_reviewer)
  end

  test "should get dashboard" do
    login(@reviewer)
    get ae_module_reviewers_dashboard_url(@project)
    assert_response :success
  end

  test "should get inbox" do
    login(@reviewer)
    get ae_module_reviewers_inbox_url(@project)
    assert_response :success
  end

  test "should get face sheet" do
    login(@reviewer)
    get ae_module_reviewers_face_sheet_url(@project)
    assert_response :success
  end
end
