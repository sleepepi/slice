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
    visit ae_module_reviewers_assignment_url(@project, ae_adverse_event_reviewer_assignments(:aes_closed_reviewer_one))
    assert_selector "h1", text: "AE#1"
    screenshot("visit-adverse-event-reviewers-assignemnt-closed")
  end

  test "visit adverse event reviewers assignment teamdone" do
    visit_login(@reviewer)
    visit ae_module_reviewers_assignment_url(@project, ae_adverse_event_reviewer_assignments(:aes_teamdone_reviewer_one))
    assert_selector "h1", text: "AE#2"
    screenshot("visit-adverse-event-reviewers-assignemnt-teamdone")
  end

  test "visit adverse event reviewers assignment pathdone" do
    visit_login(@reviewer)
    visit ae_module_reviewers_assignment_url(@project, ae_adverse_event_reviewer_assignments(:aes_pathdone_reviewer_one))
    assert_selector "h1", text: "AE#3"
    screenshot("visit-adverse-event-reviewers-assignemnt-pathdone")
  end

  test "visit adverse event reviewers assignment rvwsdone" do
    visit_login(@reviewer)
    visit ae_module_reviewers_assignment_url(@project, ae_adverse_event_reviewer_assignments(:aes_rvwsdone_reviewer_one))
    assert_selector "h1", text: "AE#4"
    screenshot("visit-adverse-event-reviewers-assignemnt-rvwsdone")
  end

  test "visit adverse event reviewers assignment pathset" do
    visit_login(@reviewer)
    visit ae_module_reviewers_assignment_url(@project, ae_adverse_event_reviewer_assignments(:aes_pathset_reviewer_one))
    assert_selector "h1", text: "AE#5"
    screenshot("visit-adverse-event-reviewers-assignemnt-pathset")
  end
end
