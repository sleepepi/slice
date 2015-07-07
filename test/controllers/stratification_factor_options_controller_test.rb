require 'test_helper'

class StratificationFactorOptionsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @project = projects(:one)
    @randomization_scheme = randomization_schemes(:one)
    @stratification_factor = stratification_factors(:one)
    @stratification_factor_option = stratification_factor_options(:one)
  end

  test "should get index" do
    get :index, project_id: @project, randomization_scheme_id: @randomization_scheme, stratification_factor_id: @stratification_factor
    assert_response :success
    assert_not_nil assigns(:stratification_factor_options)
  end

  test "should get new" do
    get :new, project_id: @project, randomization_scheme_id: @randomization_scheme, stratification_factor_id: @stratification_factor
    assert_response :success
  end

  test "should create stratification_factor_option" do
    assert_difference('StratificationFactorOption.count') do
      post :create, project_id: @project, randomization_scheme_id: @randomization_scheme, stratification_factor_id: @stratification_factor, stratification_factor_option: { label: "Other", value: 3 }
    end

    assert_redirected_to project_randomization_scheme_stratification_factor_stratification_factor_option_path(assigns(:project), assigns(:randomization_scheme), assigns(:stratification_factor), assigns(:stratification_factor_option))
  end

  test "should show stratification_factor_option" do
    get :show, project_id: @project, randomization_scheme_id: @randomization_scheme, stratification_factor_id: @stratification_factor, id: @stratification_factor_option
    assert_response :success
  end

  test "should get edit" do
    get :edit, project_id: @project, randomization_scheme_id: @randomization_scheme, stratification_factor_id: @stratification_factor, id: @stratification_factor_option
    assert_response :success
  end

  test "should update stratification_factor_option" do
    patch :update, project_id: @project, randomization_scheme_id: @randomization_scheme, stratification_factor_id: @stratification_factor, id: @stratification_factor_option, stratification_factor_option: { label: "Updated Option", value: 1 }
    assert_redirected_to project_randomization_scheme_stratification_factor_stratification_factor_option_path(assigns(:project), assigns(:randomization_scheme), assigns(:stratification_factor), assigns(:stratification_factor_option))
  end

  test "should destroy stratification_factor_option" do
    assert_difference('StratificationFactorOption.current.count', -1) do
      delete :destroy, project_id: @project, randomization_scheme_id: @randomization_scheme, stratification_factor_id: @stratification_factor, id: @stratification_factor_option
    end

    assert_redirected_to project_randomization_scheme_stratification_factor_stratification_factor_options_path(assigns(:project), assigns(:randomization_scheme), assigns(:stratification_factor))
  end
end
