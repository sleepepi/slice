# frozen_string_literal: true

require "test_helper"

# Tests for displaying reports for event designs.
class Api::V1::ReportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project = projects(:api)
    @event = events(:api_event)
    @design = designs(:api_design)
    @subject = subjects(:api_one)
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

  test "should get review" do
    get api_v1_reports_review_url(
      authentication_token: @project.id_and_token,
      event: @event,
      design: @design,
      subject_id: @subject.id,
      format: "json"
    )
    assert_response :success
  end
end
