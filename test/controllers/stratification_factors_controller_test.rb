require 'test_helper'

class StratificationFactorsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @project = projects(:one)

    @published_scheme = randomization_schemes(:one)
    @published_stratification_factor = stratification_factors(:gender)

    @randomization_scheme = randomization_schemes(:two)
    @stratification_factor = stratification_factors(:weight)
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

  test "should not get new for published randomization scheme" do
    get :new, project_id: @project, randomization_scheme_id: @published_scheme
    assert_redirected_to project_randomization_scheme_stratification_factors_path(assigns(:project), assigns(:randomization_scheme))
  end

  test "should create stratification_factor" do
    assert_difference('StratificationFactor.count') do
      post :create, project_id: @project, randomization_scheme_id: @randomization_scheme, stratification_factor: { name: "New Stratification Factor" }
    end

    assert_redirected_to project_randomization_scheme_stratification_factor_path(assigns(:project), assigns(:randomization_scheme), assigns(:stratification_factor))
  end

  test "should not create stratification factor for published randomization scheme" do
    assert_difference('StratificationFactor.count', 0) do
      post :create, project_id: @project, randomization_scheme_id: @published_scheme, stratification_factor: { name: "New Stratification Factor" }
    end

    assert_redirected_to project_randomization_scheme_stratification_factors_path(assigns(:project), assigns(:randomization_scheme))
  end

  test "should show stratification_factor" do
    get :show, project_id: @project, randomization_scheme_id: @randomization_scheme, id: @stratification_factor
    assert_response :success
  end

  test "should get edit" do
    get :edit, project_id: @project, randomization_scheme_id: @randomization_scheme, id: @stratification_factor
    assert_response :success
  end

  test "should not get edit for published randomization scheme" do
    get :edit, project_id: @project, randomization_scheme_id: @published_scheme, id: @published_stratification_factor
    assert_redirected_to project_randomization_scheme_stratification_factor_path(assigns(:project), assigns(:randomization_scheme), assigns(:stratification_factor))
  end

  test "should update stratification_factor" do
    patch :update, project_id: @project, randomization_scheme_id: @randomization_scheme, id: @stratification_factor, stratification_factor: { name: "Updated Stratification Factor" }
    assert_redirected_to project_randomization_scheme_stratification_factor_path(assigns(:project), assigns(:randomization_scheme), assigns(:stratification_factor))
  end

  test "should not update stratification factor for published randomization scheme" do
    patch :update, project_id: @project, randomization_scheme_id: @published_scheme, id: @published_stratification_factor, stratification_factor: { name: "Updated Stratification Factor" }
    assert_equal "Gender", assigns(:stratification_factor).name
    assert_redirected_to project_randomization_scheme_stratification_factor_path(assigns(:project), assigns(:randomization_scheme), assigns(:stratification_factor))
  end

  test "should destroy stratification_factor" do
    assert_difference('StratificationFactor.current.count', -1) do
      delete :destroy, project_id: @project, randomization_scheme_id: @randomization_scheme, id: @stratification_factor
    end

    assert_redirected_to project_randomization_scheme_stratification_factors_path(assigns(:project), assigns(:randomization_scheme))
  end

  test "should not destroy stratification factor for published randomization scheme" do
    assert_difference('StratificationFactor.current.count', 0) do
      delete :destroy, project_id: @project, randomization_scheme_id: @published_scheme, id: @published_stratification_factor
    end

    assert_redirected_to project_randomization_scheme_stratification_factor_path(assigns(:project), assigns(:randomization_scheme), assigns(:stratification_factor))
  end
end
