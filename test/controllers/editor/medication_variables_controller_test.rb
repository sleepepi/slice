# frozen_string_literal: true

require "test_helper"

# Tests to assure that project editors can create and update medication
# variables.
class Editor::MedicationVariablesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project_editor = users(:meds_project_editor)
    @project = projects(:medications)
    @medication_variable = medication_variables(:indication)
  end

  def medication_variable_params
    {
      name: "Special Instructions",
      autocomplete_values: "as needed\ncontinue use"
    }
  end

  test "should get index" do
    login(@project_editor)
    get editor_project_medication_variables_url(@project)
    assert_response :success
  end

  test "should get new" do
    login(@project_editor)
    get new_editor_project_medication_variable_url(@project)
    assert_response :success
  end

  test "should create medication variable" do
    login(@project_editor)
    assert_difference("MedicationVariable.count") do
      post editor_project_medication_variables_url(@project), params: {
        medication_variable: medication_variable_params
      }
    end
    assert_redirected_to editor_project_medication_variable_url(@project, MedicationVariable.last)
  end

  test "should show medication variable" do
    login(@project_editor)
    get editor_project_medication_variable_url(@project, @medication_variable)
    assert_response :success
  end

  test "should get edit" do
    login(@project_editor)
    get edit_editor_project_medication_variable_url(@project, @medication_variable)
    assert_response :success
  end

  test "should update medication_variable" do
    login(@project_editor)
    patch editor_project_medication_variable_url(@project, @medication_variable), params: {
      medication_variable: medication_variable_params
    }
    assert_redirected_to editor_project_medication_variable_url(@project, @medication_variable)
  end

  test "should destroy medication variable" do
    login(@project_editor)
    assert_difference("MedicationVariable.current.count", -1) do
      delete editor_project_medication_variable_url(@project, @medication_variable)
    end
    assert_redirected_to editor_project_medication_variables_url(@project)
  end
end
