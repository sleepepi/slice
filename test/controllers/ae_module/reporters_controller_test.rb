require "test_helper"

class AeModule::ReportersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project = projects(:aes)
    @reporter = users(:aes_project_editor)
  end

  def adverse_event_params
    {
      subject_code: "AE02",
      description: "Hospitalization after injury"
    }
  end

  test "should get adverse event overview as reporter" do
    login(@reporter)
    get ae_module_reporters_overview_url(@project)
    assert_response :success
  end

  test "should get adverse event report as reporter" do
    login(@reporter)
    get ae_module_reporters_report_url(@project)
    assert_response :success
  end

  test "should create adverse event as site editor" do
    login(@reporter)
    assert_difference("AeAdverseEvent.count") do
      post ae_module_reporters_submit_report_url(@project), params: {
        ae_adverse_event: adverse_event_params
      }
    end
    assert_redirected_to ae_module_reporters_overview_url(@project)
  end
end
