# frozen_string_literal: true

require "application_system_test_case"

# Test reporting of AEs.
class ReportersTest < ApplicationSystemTestCase
  setup do
    @project = projects(:aes)
    @adverse_event = ae_adverse_events(:closed)
    @reporter = users(:aes_project_editor)
  end

  test "visit adverse event reporters overview" do
    visit_login(@reporter)
    visit ae_module_reporters_inbox_url(@project)
    assert_selector "h1", text: "Adverse Events"
    screenshot("visit-adverse-event-reporters-overview")
  end
end
