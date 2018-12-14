# frozen_string_literal: true

require "application_system_test_case"

# Test reporting of AEs.
class ReportersTest < ApplicationSystemTestCase
  setup do
    @project = projects(:aes)
    @adverse_event = ae_adverse_events(:closed)
    @reporter = users(:aes_project_editor)
  end

  test "visit adverse event reporters inbox" do
    visit_login(@reporter)
    visit ae_module_reporters_inbox_url(@project)
    assert_selector "h1", text: "Adverse Events"
    screenshot("visit-adverse-event-reporters-inbox")
  end

  test "visit report adverse event as reporter" do
    visit_login(@reporter)
    visit ae_module_reporters_report_url(@project)
    assert_selector "h1", text: "Report Adverse Event"
    fill_in "ae_adverse_event[subject_code]", with: "AE01"
    fill_in "ae_adverse_event[description]", with: "Complication after surgery."
    screenshot("visit-report-adverse-event")
  end

  test "visit closed adverse event as reporter" do
    visit_login(@reporter)
    visit ae_module_reporters_adverse_event_url(@project, ae_adverse_events(:closed))
    assert_selector "h1", text: "AE#1"
    screenshot("visit-reporter-adverse-event-01-closed")
  end

  test "visit teamdone adverse event as reporter" do
    visit_login(@reporter)
    visit ae_module_reporters_adverse_event_url(@project, ae_adverse_events(:teamdone))
    assert_selector "h1", text: "AE#2"
    screenshot("visit-reporter-adverse-event-02-teamdone")
  end

  test "visit pathdone adverse event as reporter" do
    visit_login(@reporter)
    visit ae_module_reporters_adverse_event_url(@project, ae_adverse_events(:pathdone))
    assert_selector "h1", text: "AE#3"
    screenshot("visit-reporter-adverse-event-03-pathdone")
  end

  test "visit rvwsdone adverse event as reporter" do
    visit_login(@reporter)
    visit ae_module_reporters_adverse_event_url(@project, ae_adverse_events(:rvwsdone))
    assert_selector "h1", text: "AE#4"
    screenshot("visit-reporter-adverse-event-04-rvwsdone")
  end

  test "visit pathset adverse event as reporter" do
    visit_login(@reporter)
    visit ae_module_reporters_adverse_event_url(@project, ae_adverse_events(:pathset))
    assert_selector "h1", text: "AE#5"
    screenshot("visit-reporter-adverse-event-05-pathset")
  end

  test "visit teamindone adverse event as reporter" do
    visit_login(@reporter)
    visit ae_module_reporters_adverse_event_url(@project, ae_adverse_events(:teamindone))
    assert_selector "h1", text: "AE#6"
    screenshot("visit-reporter-adverse-event-06-teamindone")
  end

  test "visit teaminfo adverse event as reporter" do
    visit_login(@reporter)
    visit ae_module_reporters_adverse_event_url(@project, ae_adverse_events(:teaminfo))
    assert_selector "h1", text: "AE#7"
    screenshot("visit-reporter-adverse-event-07-teaminfo")
  end

  test "visit teamset adverse event as reporter" do
    visit_login(@reporter)
    visit ae_module_reporters_adverse_event_url(@project, ae_adverse_events(:teamset))
    assert_selector "h1", text: "AE#8"
    screenshot("visit-reporter-adverse-event-08-teamset")
  end

  test "visit repindone adverse event as reporter" do
    visit_login(@reporter)
    visit ae_module_reporters_adverse_event_url(@project, ae_adverse_events(:repindone))
    assert_selector "h1", text: "AE#9"
    screenshot("visit-reporter-adverse-event-09-repindone")
  end

  test "visit repinfo adverse event as reporter" do
    visit_login(@reporter)
    visit ae_module_reporters_adverse_event_url(@project, ae_adverse_events(:repinfo))
    assert_selector "h1", text: "AE#10"
    screenshot("visit-reporter-adverse-event-10-repinfo")
  end

  test "visit sheetdone adverse event as reporter" do
    visit_login(@reporter)
    visit ae_module_reporters_adverse_event_url(@project, ae_adverse_events(:sheetdone))
    assert_selector "h1", text: "AE#11"
    screenshot("visit-reporter-adverse-event-11-sheetdone")
  end

  test "visit reported adverse event as reporter" do
    visit_login(@reporter)
    visit ae_module_reporters_adverse_event_url(@project, ae_adverse_events(:reported))
    assert_selector "h1", text: "AE#12"
    screenshot("visit-reporter-adverse-event-12-reported")
  end
end
