# frozen_string_literal: true

require "application_system_test_case"

# Test for project editors to edit subject medications.
class MedicationsTest < ApplicationSystemTestCase
  setup do
    @project = projects(:medications)
    @subject = subjects(:meds_01)
    @project_editor = users(:meds_project_editor)
    @medication = medications(:one)
  end

  test "visit the index" do
    visit_login(@project_editor)
    visit project_subject_medications_url(@project, @subject)
    assert_selector "h1", text: "Medications"
    screenshot("visit-medications-index")
  end

  test "create a medication" do
    visit_login(@project_editor)
    visit project_subject_medications_url(@project, @subject)
    click_on "Add Medication"
    screenshot("create-medication")
    fill_in "medication[name]", with: @medication.name
    fill_in "medication[medication_variables][#{medication_variables(:indication).id}]", with: "Headache"
    fill_in "medication[medication_variables][#{medication_variables(:unit).id}]", with: "tablet"
    fill_in "medication[medication_variables][#{medication_variables(:frequency).id}]", with: "1X per day"
    fill_in "medication[medication_variables][#{medication_variables(:route).id}]", with: "P.O. - by mouth"
    fill_in "medication[start_date_fuzzy_mo_1]", with: "9"
    fill_in "medication[start_date_fuzzy_mo_2]", with: "9"
    fill_in "medication[start_date_fuzzy_dy_1]", with: "9"
    fill_in "medication[start_date_fuzzy_dy_2]", with: "9"
    fill_in "medication[start_date_fuzzy_yr_1]", with: "1"
    fill_in "medication[start_date_fuzzy_yr_2]", with: "9"
    fill_in "medication[start_date_fuzzy_yr_3]", with: "9"
    fill_in "medication[start_date_fuzzy_yr_4]", with: "0"
    fill_in "medication[stop_date_fuzzy_mo_1]", with: "9"
    fill_in "medication[stop_date_fuzzy_mo_2]", with: "9"
    fill_in "medication[stop_date_fuzzy_dy_1]", with: "9"
    fill_in "medication[stop_date_fuzzy_dy_2]", with: "9"
    fill_in "medication[stop_date_fuzzy_yr_1]", with: "9"
    fill_in "medication[stop_date_fuzzy_yr_2]", with: "9"
    fill_in "medication[stop_date_fuzzy_yr_3]", with: "9"
    fill_in "medication[stop_date_fuzzy_yr_4]", with: "9"
    screenshot("create-medication")
    click_on "Create Medication"
    assert_text "Medication was successfully created"
    screenshot("create-medication")
  end

  test "update a medication" do
    visit_login(@project_editor)
    visit project_subject_medications_url(@project, @subject)
    click_on "Actions", match: :first
    screenshot("update-medication")
    click_on "Edit"
    fill_in "medication[name]", with: @medication.name
    fill_in "medication[start_date_fuzzy_mo_1]", with: "1"
    fill_in "medication[start_date_fuzzy_mo_2]", with: "2"
    fill_in "medication[start_date_fuzzy_dy_1]", with: "3"
    fill_in "medication[start_date_fuzzy_dy_2]", with: "1"
    fill_in "medication[start_date_fuzzy_yr_1]", with: "1"
    fill_in "medication[start_date_fuzzy_yr_2]", with: "9"
    fill_in "medication[start_date_fuzzy_yr_3]", with: "9"
    fill_in "medication[start_date_fuzzy_yr_4]", with: "0"
    fill_in "medication[stop_date_fuzzy_mo_1]", with: ""
    fill_in "medication[stop_date_fuzzy_mo_2]", with: ""
    fill_in "medication[stop_date_fuzzy_dy_1]", with: ""
    fill_in "medication[stop_date_fuzzy_dy_2]", with: ""
    fill_in "medication[stop_date_fuzzy_yr_1]", with: ""
    fill_in "medication[stop_date_fuzzy_yr_2]", with: ""
    fill_in "medication[stop_date_fuzzy_yr_3]", with: ""
    fill_in "medication[stop_date_fuzzy_yr_4]", with: ""
    screenshot("update-medication")
    click_on "Update Medication"
    assert_text "Medication was successfully updated"
    screenshot("update-medication")
  end

  test "destroy a medication" do
    visit_login(@project_editor)
    visit project_subject_medications_url(@project, @subject)
    screenshot("destroy-medication")
    click_on "Actions", match: :first
    screenshot("destroy-medication")
    page.accept_confirm do
      click_on "Delete", match: :first
    end
    assert_text "Medication was successfully deleted"
    screenshot("destroy-medication")
  end

  test "review medications" do
    visit_login(@project_editor)
    visit project_subject_medications_url(@project, @subject)
    screenshot("review-medications")
    click_on "Start Medication Review"
    find(".btn-primary").hover
    screenshot("review-medications")
    click_on "YES"
    screenshot("review-medications")
    click_on "NO SOMETHING CHANGED"
    screenshot("review-medications")

    fill_in "medication[medication_variables][#{medication_variables(:frequency).id}]", with: "2X per day"

    screenshot("review-medications")
    click_on "Submit change and continue review"
    screenshot("review-medications")

    fill_in "medication[start_date_fuzzy_mo_1]", with: "0"
    fill_in "medication[start_date_fuzzy_mo_2]", with: "1"
    fill_in "medication[start_date_fuzzy_dy_1]", with: "3"
    fill_in "medication[start_date_fuzzy_dy_2]", with: "1"
    fill_in "medication[start_date_fuzzy_yr_1]", with: "2"
    fill_in "medication[start_date_fuzzy_yr_2]", with: "0"
    fill_in "medication[start_date_fuzzy_yr_3]", with: "1"
    fill_in "medication[start_date_fuzzy_yr_4]", with: "9"

    screenshot("review-medications")
    click_on "Submit change and continue review"

    screenshot("review-medications")
    click_on "NO STOPPED COMPLETELY"

    screenshot("review-medications")
    fill_in "medication[stop_date_fuzzy_mo_1]", with: "0"
    fill_in "medication[stop_date_fuzzy_mo_2]", with: "3"
    fill_in "medication[stop_date_fuzzy_dy_1]", with: "0"
    fill_in "medication[stop_date_fuzzy_dy_2]", with: "8"
    fill_in "medication[stop_date_fuzzy_yr_1]", with: "2"
    fill_in "medication[stop_date_fuzzy_yr_2]", with: "0"
    fill_in "medication[stop_date_fuzzy_yr_3]", with: "1"
    fill_in "medication[stop_date_fuzzy_yr_4]", with: "9"

    screenshot("review-medications")
    click_on "Submit change and continue review"
    screenshot("review-medications")

    click_on "YES"
    screenshot("review-medications")

    click_on "Add a new medication"
    screenshot("review-medications")
    fill_in "medication[name]", with: "Ouchieawaylenol"
    fill_in "medication[medication_variables][#{medication_variables(:indication).id}]", with: "Arm pain"
    fill_in "medication[medication_variables][#{medication_variables(:unit).id}]", with: "tablet"
    fill_in "medication[medication_variables][#{medication_variables(:frequency).id}]", with: "1X per day"
    fill_in "medication[medication_variables][#{medication_variables(:route).id}]", with: "P.O. - by mouth"
    fill_in "medication[start_date_fuzzy_mo_1]", with: "0"
    fill_in "medication[start_date_fuzzy_mo_2]", with: "3"
    fill_in "medication[start_date_fuzzy_dy_1]", with: "0"
    fill_in "medication[start_date_fuzzy_dy_2]", with: "8"
    fill_in "medication[start_date_fuzzy_yr_1]", with: "2"
    fill_in "medication[start_date_fuzzy_yr_2]", with: "0"
    fill_in "medication[start_date_fuzzy_yr_3]", with: "1"
    fill_in "medication[start_date_fuzzy_yr_4]", with: "9"
    screenshot("review-medications")
    click_on "Create Medication"
    screenshot("review-medications")
    click_on "medications"
    screenshot("review-medications")
  end
end
