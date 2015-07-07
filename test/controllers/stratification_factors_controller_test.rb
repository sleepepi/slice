require 'test_helper'

class StratificationFactorsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @project = projects(:one)
    @randomization_scheme = randomization_schemes(:one)
    @stratification_factor = stratification_factors(:one)
  end

  test "should get index" do
    get :index, project_id: @project, randomization_scheme_id: @randomization_scheme
    assert_response :success
    assert_not_nil assigns(:stratification_factors)
  end

  test "should get new" do
    get :new, project_id: @project, randomization_scheme_id: @randomization_scheme
    assert_response :success
  end

  test "should create stratification_factor" do
    assert_difference('StratificationFactor.count') do
      post :create, project_id: @project, randomization_scheme_id: @randomization_scheme, stratification_factor: { name: "New Stratification Factor" }
    end

    assert_redirected_to project_randomization_scheme_stratification_factor_path(assigns(:project), assigns(:randomization_scheme), assigns(:stratification_factor))
  end

  test "should show stratification_factor" do
    get :show, project_id: @project, randomization_scheme_id: @randomization_scheme, id: @stratification_factor
    assert_response :success
  end

  test "should get edit" do
    get :edit, project_id: @project, randomization_scheme_id: @randomization_scheme, id: @stratification_factor
    assert_response :success
  end

  test "should update stratification_factor" do
    patch :update, project_id: @project, randomization_scheme_id: @randomization_scheme, id: @stratification_factor, stratification_factor: { name: "Updated Stratification Factor" }
    assert_redirected_to project_randomization_scheme_stratification_factor_path(assigns(:project), assigns(:randomization_scheme), assigns(:stratification_factor))
  end

  test "should destroy stratification_factor" do
    assert_difference('StratificationFactor.current.count', -1) do
      delete :destroy, project_id: @project, randomization_scheme_id: @randomization_scheme, id: @stratification_factor
    end

    assert_redirected_to project_randomization_scheme_stratification_factors_path(assigns(:project), assigns(:randomization_scheme))
  end
end
