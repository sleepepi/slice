# frozen_string_literal: true

require "application_system_test_case"

# Test administration of AEs.
class AdminsTest < ApplicationSystemTestCase
  setup do
    @project = projects(:aes)
    @review_admin = users(:aes_review_admin)
  end

  test "visit adverse event dashboard as admin" do
    visit_login(@review_admin)
    visit ae_module_dashboard_url(@project)
    assert_selector "h1", text: "AE Module Dashboard"
    screenshot("visit-adverse-event-dashboard")
  end

  test "visit adverse event setup designs as admin" do
    visit_login(@review_admin)
    visit ae_module_admins_setup_designs_url(@project)
    assert_selector "h1", text: "Setup Designs"
    screenshot("visit-adverse-event-admins-setup-designs")
  end

  test "visit adverse event inbox as admin" do
    visit_login(@review_admin)
    visit ae_module_admins_inbox_url(@project)
    assert_selector "h1", text: "Adverse Events"
    screenshot("visit-adverse-event-admins-inbox")
  end

  test "visit closed adverse event as admin" do
    visit_login(@review_admin)
    visit ae_module_admins_adverse_event_url(@project, ae_adverse_events(:closed))
    assert_selector "h1", text: "AE#1"
    screenshot("visit-admin-adverse-event-01-closed")
  end

  test "visit closed adverse event log as admin" do
    visit_login(@review_admin)
    visit ae_module_admins_adverse_event_log_url(@project, ae_adverse_events(:closed))
    assert_selector "h1", text: "AE#1"
    screenshot("visit-admin-adverse-event-01-closed-log")
  end

  test "visit teamdone adverse event as admin" do
    visit_login(@review_admin)
    visit ae_module_admins_adverse_event_url(@project, ae_adverse_events(:teamdone))
    assert_selector "h1", text: "AE#2"
    screenshot("visit-admin-adverse-event-02-teamdone")
  end

  test "visit pathdone adverse event as admin" do
    visit_login(@review_admin)
    visit ae_module_admins_adverse_event_url(@project, ae_adverse_events(:pathdone))
    assert_selector "h1", text: "AE#3"
    screenshot("visit-admin-adverse-event-03-pathdone")
  end

  test "visit rvwsdone adverse event as admin" do
    visit_login(@review_admin)
    visit ae_module_admins_adverse_event_url(@project, ae_adverse_events(:rvwsdone))
    assert_selector "h1", text: "AE#4"
    screenshot("visit-admin-adverse-event-04-rvwsdone")
  end

  test "visit pathset adverse event as admin" do
    visit_login(@review_admin)
    visit ae_module_admins_adverse_event_url(@project, ae_adverse_events(:pathset))
    assert_selector "h1", text: "AE#5"
    screenshot("visit-admin-adverse-event-05-pathset")
  end

  test "visit teamindone adverse event as admin" do
    visit_login(@review_admin)
    visit ae_module_admins_adverse_event_url(@project, ae_adverse_events(:teamindone))
    assert_selector "h1", text: "AE#6"
    screenshot("visit-admin-adverse-event-06-teamindone")
  end

  test "visit teaminfo adverse event as admin" do
    visit_login(@review_admin)
    visit ae_module_admins_adverse_event_url(@project, ae_adverse_events(:teaminfo))
    assert_selector "h1", text: "AE#7"
    screenshot("visit-admin-adverse-event-07-teaminfo")
  end

  test "visit teamset adverse event as admin" do
    visit_login(@review_admin)
    visit ae_module_admins_adverse_event_url(@project, ae_adverse_events(:teamset))
    assert_selector "h1", text: "AE#8"
    screenshot("visit-admin-adverse-event-08-teamset")
  end

  test "visit repindone adverse event as admin" do
    visit_login(@review_admin)
    visit ae_module_admins_adverse_event_url(@project, ae_adverse_events(:repindone))
    assert_selector "h1", text: "AE#9"
    screenshot("visit-admin-adverse-event-09-repindone")
  end

  test "visit repinfo adverse event as admin" do
    visit_login(@review_admin)
    visit ae_module_admins_adverse_event_url(@project, ae_adverse_events(:repinfo))
    assert_selector "h1", text: "AE#10"
    screenshot("visit-admin-adverse-event-10-repinfo")
  end

  test "visit sheetdone adverse event as admin" do
    visit_login(@review_admin)
    visit ae_module_admins_adverse_event_url(@project, ae_adverse_events(:sheetdone))
    assert_selector "h1", text: "AE#11"
    screenshot("visit-admin-adverse-event-11-sheetdone")
  end

  test "visit reported adverse event as admin" do
    visit_login(@review_admin)
    visit ae_module_admins_adverse_event_url(@project, ae_adverse_events(:reported))
    assert_selector "h1", text: "AE#12"
    screenshot("visit-admin-adverse-event-12-reported")
  end
end
