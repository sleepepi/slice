# frozen_string_literal: true

require 'test_helper'

# Allows project editors to modify stratification factors for randomization
# schemes.
class StratificationFactorsControllerTest < ActionController::TestCase
  setup do
    @project_editor = users(:project_one_editor)
    @project = projects(:one)
    @published_scheme = randomization_schemes(:one)
    @published_stratification_factor = stratification_factors(:gender)
    @randomization_scheme = randomization_schemes(:two)
    @stratification_factor = stratification_factors(:weight)
  end

  def sf_params
    {
      name: @stratification_factor.name,
      stratifies_by_site: @stratification_factor.stratifies_by_site,
      calculation: @stratification_factor.calculation
    }
  end

  test 'should get index' do
    login(@project_editor)
    get :index, project_id: @project, randomization_scheme_id: @randomization_scheme
    assert_response :success
    assert_not_nil assigns(:stratification_factors)
  end

  test 'should get new' do
    login(@project_editor)
    get :new, project_id: @project, randomization_scheme_id: @randomization_scheme
    assert_response :success
  end

  test 'should not get new for published randomization scheme' do
    login(@project_editor)
    get :new, project_id: @project, randomization_scheme_id: @published_scheme
    assert_redirected_to(
      project_randomization_scheme_stratification_factors_path(assigns(:project), assigns(:randomization_scheme))
    )
  end

  test 'should create stratification factor' do
    login(@project_editor)
    assert_difference('StratificationFactor.count') do
      post :create, project_id: @project, randomization_scheme_id: @randomization_scheme,
                    stratification_factor: sf_params.merge(name: 'New Stratification Factor')
    end

    assert_redirected_to(
      project_randomization_scheme_stratification_factor_path(
        assigns(:project), assigns(:randomization_scheme), assigns(:stratification_factor)
      )
    )
  end

  test 'should not create stratification factor with blank name' do
    login(@project_editor)
    assert_difference('StratificationFactor.count', 0) do
      post :create, project_id: @project, randomization_scheme_id: @randomization_scheme,
                    stratification_factor: sf_params.merge(name: '')
    end
    assert_template 'new'
    assert_response :success
  end

  test 'should not create stratification factor for published randomization scheme' do
    login(@project_editor)
    assert_difference('StratificationFactor.count', 0) do
      post :create, project_id: @project, randomization_scheme_id: @published_scheme,
                    stratification_factor: sf_params.merge(name: 'New Stratification Factor')
    end
    assert_redirected_to(
      project_randomization_scheme_stratification_factors_path(assigns(:project), assigns(:randomization_scheme))
    )
  end

  test 'should show stratification factor' do
    login(@project_editor)
    get :show, project_id: @project, randomization_scheme_id: @randomization_scheme, id: @stratification_factor
    assert_response :success
  end

  test 'should not show stratification factor with invalid randomization scheme' do
    login(@project_editor)
    get :show, project_id: @project, randomization_scheme_id: -1, id: @stratification_factor
    assert_redirected_to project_randomization_schemes_path(@project)
  end

  test 'should not show stratification factor with invalid stratification factor' do
    login(@project_editor)
    get :show, project_id: @project, randomization_scheme_id: @randomization_scheme, id: -1
    assert_redirected_to project_randomization_scheme_stratification_factors_path(@project, @randomization_scheme)
  end

  test 'should get edit' do
    login(@project_editor)
    get :edit, project_id: @project, randomization_scheme_id: @randomization_scheme, id: @stratification_factor
    assert_response :success
  end

  test 'should not get edit for published randomization scheme' do
    login(@project_editor)
    get :edit, project_id: @project, randomization_scheme_id: @published_scheme, id: @published_stratification_factor
    assert_redirected_to(
      project_randomization_scheme_stratification_factor_path(
        assigns(:project), assigns(:randomization_scheme), assigns(:stratification_factor)
      )
    )
  end

  test 'should update stratification factor' do
    login(@project_editor)
    patch :update, project_id: @project, randomization_scheme_id: @randomization_scheme, id: @stratification_factor,
                   stratification_factor: sf_params.merge(name: 'Updated Stratification Factor')
    assert_redirected_to(
      project_randomization_scheme_stratification_factor_path(
        assigns(:project), assigns(:randomization_scheme), assigns(:stratification_factor)
      )
    )
  end

  test 'should update stratification factor with blank name' do
    login(@project_editor)
    patch :update, project_id: @project, randomization_scheme_id: @randomization_scheme, id: @stratification_factor,
                   stratification_factor: sf_params.merge(name: '')
    assert_template 'edit'
    assert_response :success
  end

  test 'should not update stratification factor for published randomization scheme' do
    login(@project_editor)
    patch :update, project_id: @project, randomization_scheme_id: @published_scheme,
                   id: @published_stratification_factor,
                   stratification_factor: sf_params.merge(name: 'Updated Stratification Factor')
    assert_equal 'Gender', assigns(:stratification_factor).name
    assert_redirected_to(
      project_randomization_scheme_stratification_factor_path(
        assigns(:project), assigns(:randomization_scheme), assigns(:stratification_factor)
      )
    )
  end

  test 'should destroy stratification factor' do
    login(@project_editor)
    assert_difference('StratificationFactor.current.count', -1) do
      delete :destroy, project_id: @project, randomization_scheme_id: @randomization_scheme, id: @stratification_factor
    end

    assert_redirected_to(
      project_randomization_scheme_stratification_factors_path(
        assigns(:project), assigns(:randomization_scheme)
      )
    )
  end

  test 'should not destroy stratification factor for published randomization scheme' do
    login(@project_editor)
    assert_difference('StratificationFactor.current.count', 0) do
      delete :destroy, project_id: @project, randomization_scheme_id: @published_scheme,
                       id: @published_stratification_factor
    end

    assert_redirected_to(
      project_randomization_scheme_stratification_factor_path(
        assigns(:project), assigns(:randomization_scheme), assigns(:stratification_factor)
      )
    )
  end
end
