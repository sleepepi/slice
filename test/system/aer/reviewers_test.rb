# frozen_string_literal: true

require "application_system_test_case"

# Test reviewing of AEs.
class ReviewersTest < ApplicationSystemTestCase
  setup do
    @project = projects(:aes)
    # @adverse_event = ae_adverse_events(:closed)
    @reviewer = users(:aes_team_reviewer)
  end

  test "visit adverse event reviewers inbox" do
    visit_login(@reviewer)
    visit ae_module_reviewers_inbox_url(@project)
    assert_selector "h1", text: "Adverse Events"
    screenshot("visit-adverse-event-reviewers-inbox")
  end

  test "visit adverse event reviewers assignment closed" do
    visit_login(@reviewer)
    visit ae_module_adverse_event_url(@project, ae_adverse_events(:closed))
    assert_selector "h1", text: "AE#1"
    screenshot("visit-adverse-event-reviewers-assignment-closed")
  end

  test "visit adverse event reviewers assignment teamdone" do
    visit_login(@reviewer)
    visit ae_module_adverse_event_url(@project, ae_adverse_events(:teamdone))
    assert_selector "h1", text: "AE#2"
    screenshot("visit-adverse-event-reviewers-assignment-teamdone")
  end

  test "visit adverse event reviewers assignment pathdone" do
    visit_login(@reviewer)
    visit ae_module_adverse_event_url(@project, ae_adverse_events(:pathdone))
    assert_selector "h1", text: "AE#3"
    screenshot("visit-adverse-event-reviewers-assignment-pathdone")
  end

  test "visit adverse event reviewers assignment rvwsdone" do
    visit_login(@reviewer)
    visit ae_module_adverse_event_url(@project, ae_adverse_events(:rvwsdone))
    assert_selector "h1", text: "AE#4"
    screenshot("visit-adverse-event-reviewers-assignment-rvwsdone")
  end

  test "visit adverse event reviewers assignment pathset" do
    visit_login(@reviewer)
    visit ae_module_adverse_event_url(@project, ae_adverse_events(:pathset))
    assert_selector "h1", text: "AE#5"
    screenshot("visit-adverse-event-reviewers-assignment-pathset")
  end
end
