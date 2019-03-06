require "test_helper"

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
      stop_date_fuzzy: @medication.stop_date_fuzzy
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
      post project_subject_medications_url(@project, @subject), params: { medication: medication_params }
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
