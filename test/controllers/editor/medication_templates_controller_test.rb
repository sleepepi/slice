# frozen_string_literal: true

require "test_helper"

# Tests to assure project editors can create and update subject medications.
class Editor::MedicationTemplatesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project_editor = users(:meds_project_editor)
    @project = projects(:medications)
  end

  test "should get showall" do
    login(@project_editor)
    get showall_editor_project_medication_templates_url(@project)
    assert_response :success
  end

  test "should get editall" do
    login(@project_editor)
    get editall_editor_project_medication_templates_url(@project)
    assert_response :success
  end

  test "should update all medication names" do
    login(@project_editor)
    assert_difference("MedicationTemplate.count") do
      post updateall_editor_project_medication_templates_url(@project), params: {
        medication_names: "Feelbetteryl\nSnooznomoradil\nOtherboxlenol"
      }
    end
    assert_redirected_to showall_editor_project_medication_templates_url(@project)
  end
end
