require "application_system_test_case"

class MedicationsTest < ApplicationSystemTestCase
  setup do
    @medication = medications(:one)
  end

  test "visiting the index" do
    visit medications_url
    assert_selector "h1", text: "Medications"
  end

  test "creating a Medication" do
    visit medications_url
    click_on "New Medication"

    fill_in "Name", with: @medication.name
    fill_in "Position", with: @medication.position
    fill_in "Project", with: @medication.project_id
    fill_in "Start date fuzzy", with: @medication.start_date_fuzzy
    fill_in "Stop date fuzzy", with: @medication.stop_date_fuzzy
    fill_in "Subject", with: @medication.subject_id
    click_on "Create Medication"

    assert_text "Medication was successfully created"
    click_on "Back"
  end

  test "updating a Medication" do
    visit medications_url
    click_on "Edit", match: :first

    fill_in "Name", with: @medication.name
    fill_in "Position", with: @medication.position
    fill_in "Project", with: @medication.project_id
    fill_in "Start date fuzzy", with: @medication.start_date_fuzzy
    fill_in "Stop date fuzzy", with: @medication.stop_date_fuzzy
    fill_in "Subject", with: @medication.subject_id
    click_on "Update Medication"

    assert_text "Medication was successfully updated"
    click_on "Back"
  end

  test "destroying a Medication" do
    visit medications_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Medication was successfully destroyed"
  end
end
