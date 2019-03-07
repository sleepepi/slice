# frozen_string_literal: true

require "test_helper"

# Tests to assure project editors can create and update subject medications.
class MedicationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project_editor = users(:meds_project_editor)
    @project = projects(:medications)
    @subject = subjects(:meds_01)
    @medication = medications(:one)
  end

  def medication_params
    {
      name: @medication.name,
      start_date_fuzzy: @medication.start_date_fuzzy,
      stop_date_fuzzy: @medication.stop_date_fuzzy,
      medication_variables: {
        medication_variables(:indication).id.to_s => "Some reason",
        medication_variables(:unit).id.to_s => "tablespoon",
        medication_variables(:frequency).id.to_s => "1X per day",
        medication_variables(:route).id.to_s => "S.C. - subcutaneous"
      }
    }
  end

  test "should get index" do
    login(@project_editor)
    get project_subject_medications_url(@project, @subject)
    assert_response :success
  end

  test "should get new" do
    login(@project_editor)
    get new_project_subject_medication_url(@project, @subject)
    assert_response :success
  end

  test "should create medication" do
    login(@project_editor)
    assert_difference("Medication.count") do
      assert_difference("MedicationValue.count", 4) do
        post project_subject_medications_url(@project, @subject), params: { medication: medication_params }
      end
    end
    assert_redirected_to [@project, @subject, Medication.last]
  end

  test "should show medication" do
    login(@project_editor)
    get project_subject_medication_url(@project, @subject, @medication)
    assert_response :success
  end

  test "should get edit" do
    login(@project_editor)
    get edit_project_subject_medication_url(@project, @subject, @medication)
    assert_response :success
  end

  test "should update medication" do
    login(@project_editor)
    patch project_subject_medication_url(@project, @subject, @medication), params: { medication: medication_params }
    assert_redirected_to project_subject_medication_url(@project, @subject, @medication)
  end

  test "should destroy medication" do
    login(@project_editor)
    assert_difference("Medication.current.count", -1) do
      delete project_subject_medication_url(@project, @subject, @medication)
    end
    assert_redirected_to project_subject_medications_url(@project, @subject)
  end
end
