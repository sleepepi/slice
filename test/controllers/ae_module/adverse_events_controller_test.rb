# frozen_string_literal: true

require "test_helper"

class AeModule::AdverseEventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project = projects(:aes)
    @review_admin = users(:aes_review_admin)
    @reporter = users(:aes_project_editor)
    @adverse_event = ae_adverse_events(:reported)
  end

  test "should get index as review admin" do
    login(@review_admin)
    get ae_module_adverse_events_url(@project)
    assert_response :success
  end

  test "should get index as reporter" do
    login(@reporter)
    get ae_module_adverse_events_url(@project)
    assert_response :success
  end
end
