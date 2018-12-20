require "test_helper"

class AeModule::InfoRequestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project = projects(:aes)
    @reporter = users(:aes_project_editor)
    @review_admin = users(:aes_review_admin)
    @reported = ae_adverse_events(:reported)
    @repinfo = ae_adverse_events(:repinfo)
    @info_request = ae_info_requests(:repinfo_admin_info_request_for_reporter)
  end

  def ae_info_request_params
    {
      comment: "Please fill in missing details in report form."
    }
  end

  test "should get request additional details as review admin" do
    login(@review_admin)
    get new_ae_module_info_request_url(@project, @reported)
    assert_response :success
  end

  test "should create info request as review admin" do
    login(@review_admin)
    assert_difference("AeInfoRequest.count") do
      post ae_module_info_requests_url(@project, @reported), params: {
        ae_info_request: ae_info_request_params
      }
    end
    assert_redirected_to ae_module_adverse_event_url(@project, @reported)
  end

  test "should not create info request without comment as review admin" do
    login(@review_admin)
    assert_difference("AeInfoRequest.count", 0) do
      post ae_module_info_requests_url(@project, @reported), params: {
        ae_info_request: ae_info_request_params.merge(comment: "")
      }
    end
    assert_response :success
  end

  test "should resolve info request as reporter" do
    login(@reporter)
    post resolve_ae_module_info_request_url(@project, @repinfo, @info_request)
    @info_request.reload
    assert_not_nil @info_request.resolved_at
    assert_equal @reporter, @info_request.resolver
    assert_redirected_to ae_module_adverse_event_url(@project, @repinfo)
  end
end
