# frozen_string_literal: true

require "test_helper"

# Tests to assure that site editors can submit sheet unlock requests.
class SheetUnlockRequestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project = projects(:auto_lock)
    @locked_sheet = sheets(:auto_lock)
    @sheet_unlock_request = sheet_unlock_requests(:one)
    @project_editor = users(:regular)
    @site_editor = users(:auto_lock_site_one_editor)
  end

  test "should create sheet unlock request" do
    login(@site_editor)
    assert_difference("SheetUnlockRequest.count") do
      post project_sheet_sheet_unlock_requests_url(
        @project, @locked_sheet, format: "js"
      ), params: {
        sheet_unlock_request: { reason: "Transcription Error" }
      }
    end
    assert_template "create"
    assert_response :success
  end

  test "should not create sheet unlock request without reason" do
    login(@site_editor)
    assert_difference("SheetUnlockRequest.count", 0) do
      post project_sheet_sheet_unlock_requests_url(
        @project, @locked_sheet, format: "js"
      ), params: {
        sheet_unlock_request: { reason: "" }
      }
    end
    assert_template "new"
    assert_response :success
  end

  test "should destroy sheet unlock request as site editor" do
    login(@site_editor)
    assert_difference("SheetUnlockRequest.current.count", -1) do
      delete project_sheet_sheet_unlock_request_url(
        @project,
        @locked_sheet,
        @sheet_unlock_request
      )
    end
    assert_redirected_to [@project, @locked_sheet]
  end

  test "should destroy sheet unlock request as project editor" do
    login(@project_editor)
    assert_difference("Notification.count", -1) do
      assert_difference("SheetUnlockRequest.current.count", -1) do
        delete project_sheet_sheet_unlock_request_url(
          @project,
          @locked_sheet,
          @sheet_unlock_request
        )
      end
    end
    assert_redirected_to [@project, @locked_sheet]
  end
end
