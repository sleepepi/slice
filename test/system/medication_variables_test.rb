# frozen_string_literal: true

require "application_system_test_case"

# Test for project editors to manage medication variables.
class MedicationVariablesTest < ApplicationSystemTestCase
  setup do
    @project = projects(:medications)
    @project_editor = users(:meds_project_editor)
    @medication_variable = medication_variables(:unit)
  end

  def colors
    %w(
      white silver grey black navy blue cerulean sky blue turquoise blue-green
      azure teal cyan green lime chartreuse olive yellow gold amber orange brown
      orange-red red maroon rose red-violet pink magenta purple blue-violet
      indigo violet peach apricot ochre plum
    )
  end

  test "visit the medication variable index" do
    visit_login(@project_editor)
    visit editor_project_medication_variables_url(@project)
    assert_selector "h1", text: "Medication Variables"
    screenshot("visit-medication-variable-index")
  end

  test "create a medication variable" do
    visit_login(@project_editor)
    visit editor_project_medication_variables_url(@project)
    click_on "New Medication Variable"
    screenshot("create-medication-variable")
    fill_in "medication_variable[name]", with: "Colors"
    fill_in "medication_variable[autocomplete_values]", with: colors.join("\n")
    screenshot("create-medication-variable")
    click_on "Create Medication variable"
    assert_text "Medication variable was successfully created"
    screenshot("create-medication-variable")
  end

  test "update a medication variable" do
    visit_login(@project_editor)
    visit editor_project_medication_variables_url(@project)
    click_on "Actions", match: :first
    screenshot("update-medication-variable")
    click_on "Edit"
    fill_in "medication_variable[name]", with: "Colors"
    fill_in "medication_variable[autocomplete_values]", with: colors.join("\n")
    screenshot("update-medication-variable")
    click_on "Update Medication variable"
    assert_text "Medication variable was successfully updated"
    screenshot("update-medication-variable")
  end

  test "destroy a medication variable" do
    visit_login(@project_editor)
    visit editor_project_medication_variables_url(@project)
    screenshot("destroy-medication-variable")
    click_on "Actions", match: :first
    screenshot("destroy-medication-variable")
    page.accept_confirm do
      click_on "Delete"
    end
    assert_text "Medication variable was successfully deleted"
    screenshot("destroy-medication-variable")
  end
end
