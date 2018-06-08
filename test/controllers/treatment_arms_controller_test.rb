# frozen_string_literal: true

require "test_helper"

# Tests to assure project editors can add treatment arms to randomization
# schemes.
class TreatmentArmsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project_editor = users(:project_one_editor)

    @project = projects(:one)
    @published_scheme = randomization_schemes(:one)
    @published_treatment_arm = treatment_arms(:one)

    @randomization_scheme = randomization_schemes(:two)
    @treatment_arm = treatment_arms(:four)
  end

  def treatment_arm_params
    {
      name: "New Treatment Arm",
      allocation: 1
    }
  end

  test "should get index" do
    login(@project_editor)
    get project_randomization_scheme_treatment_arms_url(
      @project, @randomization_scheme
    )
    assert_response :success
  end

  test "should get new" do
    login(@project_editor)
    get new_project_randomization_scheme_treatment_arm_url(
      @project, @randomization_scheme
    )
    assert_response :success
  end

  test "should not get new for published randomization scheme" do
    login(@project_editor)
    get new_project_randomization_scheme_treatment_arm_url(
      @project, @published_scheme
    )
    assert_redirected_to project_randomization_scheme_treatment_arms_url(
      @project, @published_scheme
    )
  end

  test "should create treatment arm" do
    login(@project_editor)
    assert_difference("TreatmentArm.count") do
      post project_randomization_scheme_treatment_arms_url(
        @project, @randomization_scheme
      ), params: {
        treatment_arm: treatment_arm_params
      }
    end

    assert_redirected_to project_randomization_scheme_treatment_arm_url(
      @project, @randomization_scheme, TreatmentArm.last
    )
  end

  test "should not create treatment arm with blank name" do
    login(@project_editor)
    assert_difference("TreatmentArm.count", 0) do
      post project_randomization_scheme_treatment_arms_url(
        @project, @randomization_scheme
      ), params: {
        treatment_arm: treatment_arm_params.merge(name: "")
      }
    end
    assert_template "new"
    assert_response :success
  end

  test "should not create treatment arm for published randomization scheme" do
    login(@project_editor)
    assert_difference("TreatmentArm.count", 0) do
      post project_randomization_scheme_treatment_arms_url(
        @project, @published_scheme
      ), params: {
        treatment_arm: treatment_arm_params
      }
    end
    assert_redirected_to project_randomization_scheme_treatment_arms_url(@project, @published_scheme)
  end

  test "should show treatment arm" do
    login(@project_editor)
    get project_randomization_scheme_treatment_arm_url(
      @project, @randomization_scheme, @treatment_arm
    )
    assert_response :success
  end

  test "should not show with invalid treatment arm" do
    login(@project_editor)
    get project_randomization_scheme_treatment_arm_url(
      @project, @randomization_scheme, -1
    )
    assert_redirected_to project_randomization_scheme_treatment_arms_url(
      @project, @randomization_scheme
    )
  end

  test "should get edit" do
    login(@project_editor)
    get edit_project_randomization_scheme_treatment_arm_url(
      @project, @randomization_scheme, @treatment_arm
    )
    assert_response :success
  end

  test "should not get edit for published randomization scheme" do
    login(@project_editor)
    get edit_project_randomization_scheme_treatment_arm_url(
      @project, @published_scheme, @published_treatment_arm
    )
    assert_redirected_to project_randomization_scheme_treatment_arm_url(
      @project, @published_scheme, @published_treatment_arm
    )
  end

  test "should update treatment arm" do
    login(@project_editor)
    patch project_randomization_scheme_treatment_arm_url(
      @project, @randomization_scheme, @treatment_arm
    ), params: {
      treatment_arm: { name: "Updated Treatment Arm", allocation: 0 }
    }
    assert_redirected_to project_randomization_scheme_treatment_arm_url(
      @project, @randomization_scheme, @treatment_arm
    )
  end

  test "should not update treatment arm with blank name" do
    login(@project_editor)
    patch project_randomization_scheme_treatment_arm_url(
      @project, @randomization_scheme, @treatment_arm
    ), params: {
      treatment_arm: { name: "", allocation: 0 }
    }
    assert_template "edit"
    assert_response :success
  end

  test "should not update treatment arm for published randomization scheme" do
    login(@project_editor)
    patch project_randomization_scheme_treatment_arm_url(
      @project, @published_scheme, @published_treatment_arm
    ), params: {
      treatment_arm: { name: "Updated Treatment Arm", allocation: 0 }
    }
    assert_equal "Treatment A", assigns(:treatment_arm).name
    assert_equal 2, assigns(:treatment_arm).allocation
    assert_redirected_to project_randomization_scheme_treatment_arm_url(
      @project, @published_scheme, @published_treatment_arm
    )
  end

  test "should destroy treatment_arm" do
    login(@project_editor)
    assert_difference("TreatmentArm.current.count", -1) do
      delete project_randomization_scheme_treatment_arm_url(
        @project, @randomization_scheme, @treatment_arm
      )
    end
    assert_redirected_to project_randomization_scheme_treatment_arms_url(@project, @randomization_scheme)
  end

  test "should not destroy treatment arm for published randomization scheme" do
    login(@project_editor)
    assert_difference("TreatmentArm.current.count", 0) do
      delete project_randomization_scheme_treatment_arm_url(
        @project, @published_scheme, @published_treatment_arm
      )
    end
    assert_redirected_to project_randomization_scheme_treatment_arm_url(
      @project, @published_scheme, @published_treatment_arm
    )
  end
end
