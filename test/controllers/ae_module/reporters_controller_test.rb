require "test_helper"

class AeModule::ReportersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project = projects(:aes)
    @reporter = users(:aes_project_editor)
    @adverse_event = ae_adverse_events(:repinfo)
    @info_request = ae_info_requests(:repinfo_admin_info_request_for_reporter)
  end

  def adverse_event_params
    {
      subject_code: "AE02",
      description: "Hospitalization after injury"
    }
  end

  test "should get adverse event overview as reporter" do
    login(@reporter)
    get ae_module_adverse_events_url(@project)
    assert_response :success
  end

  test "should get report adverse event as reporter" do
    login(@reporter)
    get new_ae_module_adverse_event_url(@project)
    assert_response :success
  end

  test "should create adverse event as reporter" do
    login(@reporter)
    assert_difference("AeAdverseEvent.count") do
      post ae_module_adverse_events_url(@project), params: {
        ae_adverse_event: adverse_event_params
      }
    end
    assert_redirected_to ae_module_adverse_event_url(@project, AeAdverseEvent.last)
  end

  test "should not create adverse event without description as reporter" do
    login(@reporter)
    assert_difference("AeAdverseEvent.count", 0) do
      post ae_module_adverse_events_url(@project), params: {
        ae_adverse_event: adverse_event_params.merge(description: "")
      }
    end
    assert_response :success
  end

  test "should get adverse event as reporter" do
    login(@reporter)
    get ae_module_adverse_event_url(@project, @adverse_event)
    assert_response :success
  end
end
