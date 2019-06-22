# frozen_string_literal: true

require "test_helper"

class AeModule::SheetsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project = projects(:aes)
    @adverse_event = ae_adverse_events(:sheetdone)
    @sheet = sheets(:aes_sheetdone_report_form)
    @reporter = users(:aes_project_editor)
  end

  test "should show sheet as reporter" do
    login(@reporter)
    get ae_module_sheet_url(@project, @adverse_event, @sheet)
    assert_response :success
  end

  test "should print sheet as reporter" do
    skip if ENV["TRAVIS"] # Skip this test on Travis since Travis can't generate PDFs
    login(@reporter)
    get ae_module_sheet_url(@project, @adverse_event, @sheet, format: "pdf")
    assert_response :success
  end
end
