require 'test_helper'

class TreatmentArmsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @project = projects(:one)
    @randomization_scheme = randomization_schemes(:one)
    @treatment_arm = treatment_arms(:one)
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

  test "should create treatment_arm" do
    assert_difference('TreatmentArm.count') do
      post :create, project_id: @project, randomization_scheme_id: @randomization_scheme, treatment_arm: { name: "New Treatment Arm", allocation: 1 }
    end

    assert_redirected_to project_randomization_scheme_treatment_arm_path(assigns(:project), assigns(:randomization_scheme), assigns(:treatment_arm))
  end

  test "should show treatment_arm" do
    get :show, project_id: @project, randomization_scheme_id: @randomization_scheme, id: @treatment_arm
    assert_response :success
  end

  test "should get edit" do
    get :edit, project_id: @project, randomization_scheme_id: @randomization_scheme, id: @treatment_arm
    assert_response :success
  end

  test "should update treatment_arm" do
    patch :update, project_id: @project, randomization_scheme_id: @randomization_scheme, id: @treatment_arm, treatment_arm: { name: "Updated Treatment Arm", allocation: 0 }
    assert_redirected_to project_randomization_scheme_treatment_arm_path(assigns(:project), assigns(:randomization_scheme), assigns(:treatment_arm))
  end

  test "should destroy treatment_arm" do
    assert_difference('TreatmentArm.current.count', -1) do
      delete :destroy, project_id: @project, randomization_scheme_id: @randomization_scheme, id: @treatment_arm
    end

    assert_redirected_to project_randomization_scheme_treatment_arms_path(assigns(:project), assigns(:randomization_scheme))
  end
end
