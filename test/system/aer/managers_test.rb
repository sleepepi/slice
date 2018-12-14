# frozen_string_literal: true

require "application_system_test_case"

# Test team manager adverse events.
class ManagersTest < ApplicationSystemTestCase
  setup do
    @project = projects(:aes)
    @team = ae_review_teams(:clinical)
    @manager = users(:aes_team_manager)
  end

  test "visit adverse event inbox as manager" do
    visit_login(@manager)
    visit ae_module_managers_inbox_url(@project)
    assert_selector "h1", text: "Adverse Events"
    screenshot("visit-adverse-event-managers-inbox")
  end

  test "visit closed adverse event as manager" do
    visit_login(@manager)
    visit ae_module_managers_adverse_event_url(@project, @team, ae_adverse_events(:closed))
    assert_selector "h1", text: "AE#1"
    screenshot("visit-manager-adverse-event-01-closed")
  end

  test "visit teamdone adverse event as manager" do
    visit_login(@manager)
    visit ae_module_managers_adverse_event_url(@project, @team, ae_adverse_events(:teamdone))
    assert_selector "h1", text: "AE#2"
    screenshot("visit-manager-adverse-event-02-teamdone")
  end

  test "visit pathdone adverse event as manager" do
    visit_login(@manager)
    visit ae_module_managers_adverse_event_url(@project, @team, ae_adverse_events(:pathdone))
    assert_selector "h1", text: "AE#3"
    screenshot("visit-manager-adverse-event-03-pathdone")
  end

  test "visit rvwsdone adverse event as manager" do
    visit_login(@manager)
    visit ae_module_managers_adverse_event_url(@project, @team, ae_adverse_events(:rvwsdone))
    assert_selector "h1", text: "AE#4"
    screenshot("visit-manager-adverse-event-04-rvwsdone")
  end

  test "visit pathset adverse event as manager" do
    visit_login(@manager)
    visit ae_module_managers_adverse_event_url(@project, @team, ae_adverse_events(:pathset))
    assert_selector "h1", text: "AE#5"
    screenshot("visit-manager-adverse-event-05-pathset")
  end

  test "visit teamindone adverse event as manager" do
    visit_login(@manager)
    visit ae_module_managers_adverse_event_url(@project, @team, ae_adverse_events(:teamindone))
    assert_selector "h1", text: "AE#6"
    screenshot("visit-manager-adverse-event-06-teamindone")
  end

  test "visit teaminfo adverse event as manager" do
    visit_login(@manager)
    visit ae_module_managers_adverse_event_url(@project, @team, ae_adverse_events(:teaminfo))
    assert_selector "h1", text: "AE#7"
    screenshot("visit-manager-adverse-event-07-teaminfo")
  end

  test "visit teamset adverse event as manager" do
    visit_login(@manager)
    visit ae_module_managers_adverse_event_url(@project, @team, ae_adverse_events(:teamset))
    assert_selector "h1", text: "AE#8"
    screenshot("visit-manager-adverse-event-08-teamset")
  end
end
