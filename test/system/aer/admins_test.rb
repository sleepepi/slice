# frozen_string_literal: true

require "application_system_test_case"

# Test administration of AEs.
class AdminsTest < ApplicationSystemTestCase
  setup do
    @project = projects(:aes)
    @review_admin = users(:aes_review_admin)
  end

  test "visit adverse event setup designs as admin" do
    visit_login(@review_admin)
    visit ae_module_admins_setup_designs_url(@project)
    assert_selector "h1", text: "Setup Designs"
    screenshot("visit-adverse-event-admins-setup-designs")
  end

  test "visit adverse event inbox as admin" do
    visit_login(@review_admin)
    visit ae_module_adverse_events_url(@project)
    assert_selector "h1", text: "Adverse Events"
    screenshot("visit-adverse-event-admins-inbox")
  end

  test "visit closed adverse event as admin" do
    visit_login(@review_admin)
    visit ae_module_adverse_event_url(@project, ae_adverse_events(:closed))
    assert_selector "h1", text: "AE#1"
    screenshot("visit-admin-adverse-event-01-closed")
  end

  test "visit closed adverse event log as admin" do
    visit_login(@review_admin)
    visit log_ae_module_adverse_event_url(@project, ae_adverse_events(:closed))
    assert_selector "h1", text: "AE#1"
    screenshot("visit-admin-adverse-event-01-closed-log")
  end

  test "visit teamdone adverse event as admin" do
    visit_login(@review_admin)
    visit ae_module_adverse_event_url(@project, ae_adverse_events(:teamdone))
    assert_selector "h1", text: "AE#2"
    screenshot("visit-admin-adverse-event-02-teamdone")
  end

  test "visit teamdone adverse event log as admin" do
    visit_login(@review_admin)
    visit log_ae_module_adverse_event_url(@project, ae_adverse_events(:teamdone))
    assert_selector "h1", text: "AE#2"
    screenshot("visit-admin-adverse-event-02-teamdone-log")
  end

  test "visit pathdone adverse event as admin" do
    visit_login(@review_admin)
    visit ae_module_adverse_event_url(@project, ae_adverse_events(:pathdone))
    assert_selector "h1", text: "AE#3"
    screenshot("visit-admin-adverse-event-03-pathdone")
  end

  test "visit pathdone adverse event log as admin" do
    visit_login(@review_admin)
    visit log_ae_module_adverse_event_url(@project, ae_adverse_events(:pathdone))
    assert_selector "h1", text: "AE#3"
    screenshot("visit-admin-adverse-event-03-pathdone-log")
  end

  test "visit rvwsdone adverse event as admin" do
    visit_login(@review_admin)
    visit ae_module_adverse_event_url(@project, ae_adverse_events(:rvwsdone))
    assert_selector "h1", text: "AE#4"
    screenshot("visit-admin-adverse-event-04-rvwsdone")
  end

  test "visit rvwsdone adverse event log as admin" do
    visit_login(@review_admin)
    visit log_ae_module_adverse_event_url(@project, ae_adverse_events(:rvwsdone))
    assert_selector "h1", text: "AE#4"
    screenshot("visit-admin-adverse-event-04-rvwsdone-log")
  end

  test "visit pathset adverse event as admin" do
    visit_login(@review_admin)
    visit ae_module_adverse_event_url(@project, ae_adverse_events(:pathset))
    assert_selector "h1", text: "AE#5"
    screenshot("visit-admin-adverse-event-05-pathset")
  end

  test "visit pathset adverse event log as admin" do
    visit_login(@review_admin)
    visit log_ae_module_adverse_event_url(@project, ae_adverse_events(:pathset))
    assert_selector "h1", text: "AE#5"
    screenshot("visit-admin-adverse-event-05-pathset-log")
  end

  test "visit teamindone adverse event as admin" do
    visit_login(@review_admin)
    visit ae_module_adverse_event_url(@project, ae_adverse_events(:teamindone))
    assert_selector "h1", text: "AE#6"
    screenshot("visit-admin-adverse-event-06-teamindone")
  end

  test "visit teamindone adverse event log as admin" do
    visit_login(@review_admin)
    visit log_ae_module_adverse_event_url(@project, ae_adverse_events(:teamindone))
    assert_selector "h1", text: "AE#6"
    screenshot("visit-admin-adverse-event-06-teamindone-log")
  end

  test "visit teaminfo adverse event as admin" do
    visit_login(@review_admin)
    visit ae_module_adverse_event_url(@project, ae_adverse_events(:teaminfo))
    assert_selector "h1", text: "AE#7"
    screenshot("visit-admin-adverse-event-07-teaminfo")
  end

  test "visit teaminfo adverse event log as admin" do
    visit_login(@review_admin)
    visit log_ae_module_adverse_event_url(@project, ae_adverse_events(:teaminfo))
    assert_selector "h1", text: "AE#7"
    screenshot("visit-admin-adverse-event-07-teaminfo-log")
  end

  test "visit teamset adverse event as admin" do
    visit_login(@review_admin)
    visit ae_module_adverse_event_url(@project, ae_adverse_events(:teamset))
    assert_selector "h1", text: "AE#8"
    screenshot("visit-admin-adverse-event-08-teamset")
  end

  test "visit teamset adverse event log as admin" do
    visit_login(@review_admin)
    visit log_ae_module_adverse_event_url(@project, ae_adverse_events(:teamset))
    assert_selector "h1", text: "AE#8"
    screenshot("visit-admin-adverse-event-08-teamset-log")
  end

  test "visit repindone adverse event as admin" do
    visit_login(@review_admin)
    visit ae_module_adverse_event_url(@project, ae_adverse_events(:repindone))
    assert_selector "h1", text: "AE#9"
    screenshot("visit-admin-adverse-event-09-repindone")
  end

  test "visit repindone adverse event log as admin" do
    visit_login(@review_admin)
    visit log_ae_module_adverse_event_url(@project, ae_adverse_events(:repindone))
    assert_selector "h1", text: "AE#9"
    screenshot("visit-admin-adverse-event-09-repindone-log")
  end

  test "visit repinfo adverse event as admin" do
    visit_login(@review_admin)
    visit ae_module_adverse_event_url(@project, ae_adverse_events(:repinfo))
    assert_selector "h1", text: "AE#10"
    screenshot("visit-admin-adverse-event-10-repinfo")
  end

  test "visit repinfo adverse event log as admin" do
    visit_login(@review_admin)
    visit log_ae_module_adverse_event_url(@project, ae_adverse_events(:repinfo))
    assert_selector "h1", text: "AE#10"
    screenshot("visit-admin-adverse-event-10-repinfo-log")
  end

  test "visit sheetdone adverse event as admin" do
    visit_login(@review_admin)
    visit ae_module_adverse_event_url(@project, ae_adverse_events(:sheetdone))
    assert_selector "h1", text: "AE#11"
    screenshot("visit-admin-adverse-event-11-sheetdone")
  end

  test "visit sheetdone adverse event log as admin" do
    visit_login(@review_admin)
    visit log_ae_module_adverse_event_url(@project, ae_adverse_events(:sheetdone))
    assert_selector "h1", text: "AE#11"
    screenshot("visit-admin-adverse-event-11-sheetdone-log")
  end

  test "visit reported adverse event as admin" do
    visit_login(@review_admin)
    visit ae_module_adverse_event_url(@project, ae_adverse_events(:reported))
    assert_selector "h1", text: "AE#12"
    screenshot("visit-admin-adverse-event-12-reported")
  end

  test "visit reported adverse event log as admin" do
    visit_login(@review_admin)
    visit log_ae_module_adverse_event_url(@project, ae_adverse_events(:reported))
    assert_selector "h1", text: "AE#12"
    screenshot("visit-admin-adverse-event-12-reported-log")
  end
end
