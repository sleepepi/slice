# frozen_string_literal: true

require 'test_helper'

class TreatmentArmsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @project = projects(:one)
    @published_scheme = randomization_schemes(:one)
    @published_treatment_arm = treatment_arms(:one)

    @randomization_scheme = randomization_schemes(:two)
    @treatment_arm = treatment_arms(:four)
  end

  test "should get index" do
    get :index, project_id: @project, randomization_scheme_id: @randomization_scheme
    assert_response :success
    assert_not_nil assigns(:treatment_arms)
  end

  test "should get new" do
    get :new, project_id: @project, randomization_scheme_id: @randomization_scheme
    assert_response :success
  end

  test "should not get new for published randomization scheme" do
    get :new, project_id: @project, randomization_scheme_id: @published_scheme
    assert_redirected_to project_randomization_scheme_treatment_arms_path(assigns(:project), assigns(:randomization_scheme))
  end

  test "should create treatment_arm" do
    assert_difference('TreatmentArm.count') do
      post :create, project_id: @project, randomization_scheme_id: @randomization_scheme, treatment_arm: { name: "New Treatment Arm", allocation: 1 }
    end

    assert_redirected_to project_randomization_scheme_treatment_arm_path(assigns(:project), assigns(:randomization_scheme), assigns(:treatment_arm))
  end

  test "should not create treatment arm for published randomization scheme" do
    assert_difference('TreatmentArm.count', 0) do
      post :create, project_id: @project, randomization_scheme_id: @published_scheme, treatment_arm: { name: "New Treatment Arm Two", allocation: 1 }
    end

    assert_redirected_to project_randomization_scheme_treatment_arms_path(assigns(:project), assigns(:randomization_scheme))
  end

  test "should show treatment_arm" do
    get :show, project_id: @project, randomization_scheme_id: @randomization_scheme, id: @treatment_arm
    assert_response :success
  end

  test "should get edit" do
    get :edit, project_id: @project, randomization_scheme_id: @randomization_scheme, id: @treatment_arm
    assert_response :success
  end

  test "should not get edit for published randomization scheme" do
    get :edit, project_id: @project, randomization_scheme_id: @published_scheme, id: @published_treatment_arm
    assert_redirected_to project_randomization_scheme_treatment_arm_path(assigns(:project), assigns(:randomization_scheme), assigns(:treatment_arm))
  end

  test "should update treatment arm" do
    patch :update, project_id: @project, randomization_scheme_id: @randomization_scheme, id: @treatment_arm, treatment_arm: { name: "Updated Treatment Arm", allocation: 0 }
    assert_redirected_to project_randomization_scheme_treatment_arm_path(assigns(:project), assigns(:randomization_scheme), assigns(:treatment_arm))
  end

  test "should not update treatment arm for published randomization scheme" do
    patch :update, project_id: @project, randomization_scheme_id: @published_scheme, id: @published_treatment_arm, treatment_arm: { name: "Updated Treatment Arm", allocation: 0 }
    assert_equal "Treatment A", assigns(:treatment_arm).name
    assert_equal 2, assigns(:treatment_arm).allocation
    assert_redirected_to project_randomization_scheme_treatment_arm_path(assigns(:project), assigns(:randomization_scheme), assigns(:treatment_arm))
  end

  test "should destroy treatment_arm" do
    assert_difference('TreatmentArm.current.count', -1) do
      delete :destroy, project_id: @project, randomization_scheme_id: @randomization_scheme, id: @treatment_arm
    end

    assert_redirected_to project_randomization_scheme_treatment_arms_path(assigns(:project), assigns(:randomization_scheme))
  end

  test "should not destroy treatment arm for published randomization scheme" do
    assert_difference('TreatmentArm.current.count', 0) do
      delete :destroy, project_id: @project, randomization_scheme_id: @published_scheme, id: @published_treatment_arm
    end

    assert_redirected_to project_randomization_scheme_treatment_arm_path(assigns(:project), assigns(:randomization_scheme), assigns(:treatment_arm))
  end
end
