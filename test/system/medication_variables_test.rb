require "application_system_test_case"

class MedicationVariablesTest < ApplicationSystemTestCase
  setup do
    @medication_variable = medication_variables(:one)
  end

  test "visiting the index" do
    visit medication_variables_url
    assert_selector "h1", text: "Medication Variables"
  end

  test "creating a Medication variable" do
    visit medication_variables_url
    click_on "New Medication Variable"

    fill_in "Autocomplete values", with: @medication_variable.autocomplete_values
    check "Deleted" if @medication_variable.deleted
    fill_in "Name", with: @medication_variable.name
    fill_in "Project", with: @medication_variable.project_id
    click_on "Create Medication variable"

    assert_text "Medication variable was successfully created"
    click_on "Back"
  end

  test "updating a Medication variable" do
    visit medication_variables_url
    click_on "Edit", match: :first

    fill_in "Autocomplete values", with: @medication_variable.autocomplete_values
    check "Deleted" if @medication_variable.deleted
    fill_in "Name", with: @medication_variable.name
    fill_in "Project", with: @medication_variable.project_id
    click_on "Update Medication variable"

    assert_text "Medication variable was successfully updated"
    click_on "Back"
  end

  test "destroying a Medication variable" do
    visit medication_variables_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Medication variable was successfully destroyed"
  end
end
