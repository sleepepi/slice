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
      start_date_fuzzy_edit: "1",
      start_date_fuzzy_mo_1: "0",
      start_date_fuzzy_mo_2: "1",
      start_date_fuzzy_dy_1: "0",
      start_date_fuzzy_dy_2: "1",
      start_date_fuzzy_yr_1: "1",
      start_date_fuzzy_yr_2: "9",
      start_date_fuzzy_yr_3: "9",
      start_date_fuzzy_yr_4: "0",
      stop_date_fuzzy_edit: "1",
      stop_date_fuzzy_mo_1: "1",
      stop_date_fuzzy_mo_2: "2",
      stop_date_fuzzy_dy_1: "3",
      stop_date_fuzzy_dy_2: "1",
      stop_date_fuzzy_yr_1: "1",
      stop_date_fuzzy_yr_2: "9",
      stop_date_fuzzy_yr_3: "9",
      stop_date_fuzzy_yr_4: "0",
      medication_variables: {
        medication_variables(:indication).id.to_s => "Some reason",
        medication_variables(:unit).id.to_s => "tablespoon",
        medication_variables(:frequency).id.to_s => "1X per day",
        medication_variables(:route).id.to_s => "S.C. - subcutaneous"
      }
    }
  end

  def create_split_medication
    @subject.medications.where(
      project: @project,
      name: medications(:two).name,
      parent_medication: medications(:two)
    ).create
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

  test "should not create medication with blank name" do
    login(@project_editor)
    assert_difference("Medication.count", 0) do
      assert_difference("MedicationValue.count", 0) do
        post project_subject_medications_url(@project, @subject), params: {
          medication: medication_params.merge(name: "")
        }
      end
    end
    assert_response :success
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

  test "should not update medication with blank name" do
    login(@project_editor)
    patch project_subject_medication_url(@project, @subject, @medication), params: {
      medication: medication_params.merge(name: "")
    }
    assert_response :success
  end

  test "should destroy medication" do
    login(@project_editor)
    assert_difference("Medication.current.count", -1) do
      delete project_subject_medication_url(@project, @subject, @medication)
    end
    assert_redirected_to project_subject_medications_url(@project, @subject)
  end

  test "should start review" do
    login(@project_editor)
    assert_difference("Medication.where.not(position: nil).count", 4) do
      post start_review_project_subject_medications_url(@project, @subject)
    end
    assert_redirected_to review_project_subject_medication_path(@project, @subject, medications(:two))
  end

  test "should continue review" do
    login(@project_editor)
    post continue_review_project_subject_medications_url(@project, @subject)
    assert_redirected_to review_complete_project_subject_medications_path(@project, @subject)
  end

  test "should review medication" do
    login(@project_editor)
    get review_project_subject_medication_path(@project, @subject, medications(:two))
    assert_response :success
  end

  test "should mark medication as still taking" do
    login(@project_editor)
    post still_taking_project_subject_medication_path(@project, @subject, medications(:two))
    assert_redirected_to review_complete_project_subject_medications_path(@project, @subject)
  end

  test "should get medication something changed" do
    login(@project_editor)
    get something_changed_project_subject_medication_path(@project, @subject, medications(:two))
    assert_response :success
  end

  test "should submit medication something changed" do
    login(@project_editor)
    assert_difference("Medication.where.not(parent_medication_id: nil).count") do
      assert_difference("MedicationValue.count", 4) do
        post submit_something_changed_project_subject_medication_path(
          @project, @subject, medications(:two)
        ), params: {
          medication: {
            name: medications(:two).name,
            medication_variables: {
              medication_variables(:indication).id.to_s => "Some other reason",
              medication_variables(:unit).id.to_s => "teaspoon",
              medication_variables(:frequency).id.to_s => "2X per day",
              medication_variables(:route).id.to_s => "P.O. - by mouth"
            }
          }
        }
      end
    end
    assert_redirected_to change_occurred_project_subject_medication_path(
      @project, @subject, Medication.where.not(parent_medication_id: nil).last
    )
  end

  test "should not submit medication something changed with blank medication name" do
    login(@project_editor)
    split_medication = create_split_medication
    post submit_something_changed_project_subject_medication_path(
      @project, @subject, split_medication
    ), params: {
      medication: {
        name: "",
        medication_variables: {
          medication_variables(:indication).id.to_s => "Some other reason",
          medication_variables(:unit).id.to_s => "teaspoon",
          medication_variables(:frequency).id.to_s => "2X per day",
          medication_variables(:route).id.to_s => "P.O. - by mouth"
        }
      }
    }
    assert_response :success
  end

  test "should get medication change occurred" do
    login(@project_editor)
    get change_occurred_project_subject_medication_path(@project, @subject, create_split_medication)
    assert_response :success
  end

  test "should submit medication change occurred" do
    login(@project_editor)
    post submit_change_occurred_project_subject_medication_path(@project, @subject, create_split_medication), params: {
      medication: {
        start_date_fuzzy_edit: "1",
        start_date_fuzzy_mo_1: "0",
        start_date_fuzzy_mo_2: "3",
        start_date_fuzzy_dy_1: "0",
        start_date_fuzzy_dy_2: "8",
        start_date_fuzzy_yr_1: "2",
        start_date_fuzzy_yr_2: "0",
        start_date_fuzzy_yr_3: "1",
        start_date_fuzzy_yr_4: "9"
      }
    }
    assert_redirected_to review_complete_project_subject_medications_path(@project, @subject)
  end

  test "should not submit medication change occurred with invalid date" do
    login(@project_editor)
    post submit_change_occurred_project_subject_medication_path(@project, @subject, create_split_medication), params: {
      medication: {
        start_date_fuzzy_edit: "1",
        start_date_fuzzy_mo_1: "0",
        start_date_fuzzy_mo_2: "2",
        start_date_fuzzy_dy_1: "3",
        start_date_fuzzy_dy_2: "1",
        start_date_fuzzy_yr_1: "2",
        start_date_fuzzy_yr_2: "0",
        start_date_fuzzy_yr_3: "1",
        start_date_fuzzy_yr_4: "9"
      }
    }
    assert_response :success
  end

  test "should get medication stopped completely" do
    login(@project_editor)
    get stopped_completely_project_subject_medication_path(@project, @subject, medications(:two))
    assert_response :success
  end

  test "should submit medication stopped completely" do
    login(@project_editor)
    post submit_stopped_completely_project_subject_medication_path(@project, @subject, medications(:two)), params: {
      medication: {
        stop_date_fuzzy_edit: "1",
        stop_date_fuzzy_mo_1: "0",
        stop_date_fuzzy_mo_2: "3",
        stop_date_fuzzy_dy_1: "0",
        stop_date_fuzzy_dy_2: "8",
        stop_date_fuzzy_yr_1: "2",
        stop_date_fuzzy_yr_2: "0",
        stop_date_fuzzy_yr_3: "1",
        stop_date_fuzzy_yr_4: "9"
      }
    }
    assert_redirected_to review_complete_project_subject_medications_path(@project, @subject)
  end

  test "should not submit medication stopped completely with invalid date" do
    login(@project_editor)
    post submit_stopped_completely_project_subject_medication_path(@project, @subject, medications(:two)), params: {
      medication: {
        stop_date_fuzzy_edit: "1",
        stop_date_fuzzy_mo_1: "0",
        stop_date_fuzzy_mo_2: "2",
        stop_date_fuzzy_dy_1: "3",
        stop_date_fuzzy_dy_2: "1",
        stop_date_fuzzy_yr_1: "2",
        stop_date_fuzzy_yr_2: "0",
        stop_date_fuzzy_yr_3: "1",
        stop_date_fuzzy_yr_4: "9"
      }
    }
    assert_response :success
  end

  test "should get autocomplete" do
    login(@project_editor)
    get autocomplete_project_subject_medications_url(@project, @subject, format: "json"), params: {
      medication_variable_id: medication_variables(:unit), search: "mi"
    }
    assert_response :success
  end
end
