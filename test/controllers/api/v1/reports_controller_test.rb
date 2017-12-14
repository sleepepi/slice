require 'test_helper'

class Api::V1::ReportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project = projects(:api)
    @event = events(:api_event)
    @design = designs(:api_design)
  end

  test "should get show" do
    get api_v1_reports_show_url(
      authentication_token: @project.id_and_token,
      event: @event,
      design: @design,
      format: "json"
    )
    assert_response :success
  end
end
