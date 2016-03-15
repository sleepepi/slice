# frozen_string_literal: true

require 'test_helper'

# Tests to assure project editors can adde treatment arms to randomization
# schemes
class TreatmentArmsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @project = projects(:one)
    @published_scheme = randomization_schemes(:one)
    @published_treatment_arm = treatment_arms(:one)

    @randomization_scheme = randomization_schemes(:two)
    @treatment_arm = treatment_arms(:four)
  end

  def treatment_arm_params
    {
      name: 'New Treatment Arm',
      allocation: 1
    }
  end

  test 'should get index' do
    get :index, params: {
      project_id: @project, randomization_scheme_id: @randomization_scheme
    }
    assert_response :success
    assert_not_nil assigns(:treatment_arms)
  end

  test 'should get new' do
    get :new, params: {
      project_id: @project, randomization_scheme_id: @randomization_scheme
    }
    assert_response :success
  end

  test 'should not get new for published randomization scheme' do
    get :new, params: {
      project_id: @project, randomization_scheme_id: @published_scheme
    }
    assert_redirected_to project_randomization_scheme_treatment_arms_path(
      @project, @published_scheme
    )
  end

  test 'should create treatment arm' do
    assert_difference('TreatmentArm.count') do
      post :create, params: {
        project_id: @project, randomization_scheme_id: @randomization_scheme,
        treatment_arm: treatment_arm_params
      }
    end

    assert_redirected_to project_randomization_scheme_treatment_arm_path(
      @project, @randomization_scheme, TreatmentArm.last
    )
  end

  test 'should not create treatment arm with blank name' do
    assert_difference('TreatmentArm.count', 0) do
      post :create, params: {
        project_id: @project, randomization_scheme_id: @randomization_scheme,
        treatment_arm: treatment_arm_params.merge(name: '')
      }
    end
    assert_template 'new'
    assert_response :success
  end

  test 'should not create treatment arm for published randomization scheme' do
    assert_difference('TreatmentArm.count', 0) do
      post :create, params: {
        project_id: @project, randomization_scheme_id: @published_scheme,
        treatment_arm: treatment_arm_params
      }
    end
    assert_redirected_to project_randomization_scheme_treatment_arms_path(@project, @published_scheme)
  end

  test 'should show treatment arm' do
    get :show, params: {
      project_id: @project, randomization_scheme_id: @randomization_scheme,
      id: @treatment_arm
    }
    assert_response :success
  end

  test 'should not show with invalid treatment arm' do
    get :show, params: {
      project_id: @project, randomization_scheme_id: @randomization_scheme,
      id: -1
    }
    assert_redirected_to project_randomization_scheme_treatment_arms_path(
      @project, @randomization_scheme
    )
  end

  test 'should get edit' do
    get :edit, params: {
      project_id: @project, randomization_scheme_id: @randomization_scheme,
      id: @treatment_arm
    }
    assert_response :success
  end

  test 'should not get edit for published randomization scheme' do
    get :edit, params: {
      project_id: @project, randomization_scheme_id: @published_scheme,
      id: @published_treatment_arm
    }
    assert_redirected_to project_randomization_scheme_treatment_arm_path(
      @project, @published_scheme, @published_treatment_arm
    )
  end

  test 'should update treatment arm' do
    patch :update, params: {
      project_id: @project, randomization_scheme_id: @randomization_scheme,
      id: @treatment_arm,
      treatment_arm: { name: 'Updated Treatment Arm', allocation: 0 }
    }
    assert_redirected_to project_randomization_scheme_treatment_arm_path(
      @project, @randomization_scheme, @treatment_arm
    )
  end

  test 'should not update treatment arm with blank name' do
    patch :update, params: {
      project_id: @project, randomization_scheme_id: @randomization_scheme,
      id: @treatment_arm,
      treatment_arm: { name: '', allocation: 0 }
    }
    assert_template 'edit'
    assert_response :success
  end

  test 'should not update treatment arm for published randomization scheme' do
    patch :update, params: {
      project_id: @project, randomization_scheme_id: @published_scheme,
      id: @published_treatment_arm,
      treatment_arm: { name: 'Updated Treatment Arm', allocation: 0 }
    }
    assert_equal 'Treatment A', assigns(:treatment_arm).name
    assert_equal 2, assigns(:treatment_arm).allocation
    assert_redirected_to project_randomization_scheme_treatment_arm_path(
      @project, @published_scheme, @published_treatment_arm
    )
  end

  test 'should destroy treatment_arm' do
    assert_difference('TreatmentArm.current.count', -1) do
      delete :destroy, params: {
        project_id: @project, randomization_scheme_id: @randomization_scheme,
        id: @treatment_arm
      }
    end
    assert_redirected_to project_randomization_scheme_treatment_arms_path(@project, @randomization_scheme)
  end

  test 'should not destroy treatment arm for published randomization scheme' do
    assert_difference('TreatmentArm.current.count', 0) do
      delete :destroy, params: {
        project_id: @project, randomization_scheme_id: @published_scheme,
        id: @published_treatment_arm
      }
    end
    assert_redirected_to project_randomization_scheme_treatment_arm_path(
      @project, @published_scheme, @published_treatment_arm
    )
  end
end
