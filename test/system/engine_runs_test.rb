# frozen_string_literal: true

require "application_system_test_case"

# Test viewing engine run statistics.
class EngineRunsTest < ApplicationSystemTestCase
  setup do
    @engine_run = engine_runs(:one)
    @admin = users(:admin)
  end

  test "visit the index" do
    visit_login(@admin)
    visit admin_engine_runs_url
    assert_selector "h1", text: "Engine Runs"
    screenshot("visit-engine-runs-index")
  end

  test "destroy an engine run" do
    visit_login(@admin)
    visit admin_engine_runs_url
    screenshot("destroy-an-engine-run")
    page.accept_confirm do
      click_element ".fa-trash-alt"
    end
    assert_text "Engine run was successfully deleted"
    screenshot("destroy-an-engine-run")
  end
end
