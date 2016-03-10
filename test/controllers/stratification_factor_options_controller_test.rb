# frozen_string_literal: true

require 'test_helper'

# Tests to assure that project editors can modify stratification factor options.
class StratificationFactorOptionsControllerTest < ActionController::TestCase
  setup do
    @project = projects(:one)
    @published_scheme = randomization_schemes(:one)
    @published_stratification_factor = stratification_factors(:gender)
    @published_stratification_factor_option = stratification_factor_options(:male)
    @randomization_scheme = randomization_schemes(:two)
    @stratification_factor = stratification_factors(:weight)
    @stratification_factor_option = stratification_factor_options(:lowweight)
    @project_editor = users(:project_one_editor)
  end

  test 'should get index' do
    login(@project_editor)
    get :index, project_id: @project,
                randomization_scheme_id: @published_scheme,
                stratification_factor_id: @published_stratification_factor
    assert_response :success
  end

  test 'should get new' do
    login(@project_editor)
    get :new, project_id: @project,
              randomization_scheme_id: @published_scheme,
              stratification_factor_id: @published_stratification_factor
    assert_response :success
  end

  test 'should create stratification factor option' do
    login(@project_editor)
    assert_difference('StratificationFactorOption.count') do
      post :create, project_id: @project,
                    randomization_scheme_id: @published_scheme,
                    stratification_factor_id: @published_stratification_factor,
                    stratification_factor_option: { label: 'Other', value: 3 }
    end

    assert_redirected_to project_randomization_scheme_stratification_factor_stratification_factor_option_path(
      assigns(:project), assigns(:randomization_scheme),
      assigns(:stratification_factor), assigns(:stratification_factor_option)
    )
  end

  test 'should not create stratification factor option without label' do
    login(@project_editor)
    assert_difference('StratificationFactorOption.count', 0) do
      post :create, project_id: @project,
                    randomization_scheme_id: @published_scheme,
                    stratification_factor_id: @published_stratification_factor,
                    stratification_factor_option: { label: '', value: 3 }
    end

    assert_template 'new'
    assert_response :success
  end

  test 'should show stratification factor option' do
    login(@project_editor)
    get :show, project_id: @project,
               randomization_scheme_id: @published_scheme,
               stratification_factor_id: @published_stratification_factor,
               id: @published_stratification_factor_option
    assert_response :success
  end

  test 'should not show stratification factor option with invalid stratification factor' do
    login(@project_editor)
    get :show, project_id: @project,
               randomization_scheme_id: @published_scheme,
               stratification_factor_id: -1,
               id: @published_stratification_factor_option
    assert_redirected_to project_randomization_scheme_stratification_factors_path(@project, @published_scheme)
  end

  test 'should not show stratification factor option with invalid stratification factor option' do
    login(@project_editor)
    get :show, project_id: @project,
               randomization_scheme_id: @published_scheme,
               stratification_factor_id: @published_stratification_factor,
               id: -1
    assert_redirected_to project_randomization_scheme_stratification_factor_stratification_factor_options_path(
      @project, @published_scheme, @published_stratification_factor
    )
  end

  test 'should get edit' do
    login(@project_editor)
    get :edit, project_id: @project,
               randomization_scheme_id: @published_scheme,
               stratification_factor_id: @published_stratification_factor,
               id: @published_stratification_factor_option
    assert_response :success
  end

  test 'should update stratification factor option' do
    login(@project_editor)
    patch :update, project_id: @project,
                   randomization_scheme_id: @published_scheme,
                   stratification_factor_id: @published_stratification_factor,
                   id: @published_stratification_factor_option,
                   stratification_factor_option: { label: 'Updated Option', value: 1 }
    assert_redirected_to project_randomization_scheme_stratification_factor_stratification_factor_option_path(
      assigns(:project), assigns(:randomization_scheme),
      assigns(:stratification_factor), assigns(:stratification_factor_option)
    )
  end

  test 'should not update stratification factor option with blank label' do
    login(@project_editor)
    patch :update, project_id: @project,
                   randomization_scheme_id: @published_scheme,
                   stratification_factor_id: @published_stratification_factor,
                   id: @published_stratification_factor_option,
                   stratification_factor_option: { label: '', value: 1 }
    assert_template 'edit'
    assert_response :success
  end

  test 'should destroy stratification factor option' do
    login(@project_editor)
    assert_difference('StratificationFactorOption.current.count', -1) do
      delete :destroy, project_id: @project,
                       randomization_scheme_id: @randomization_scheme,
                       stratification_factor_id: @stratification_factor,
                       id: @stratification_factor_option
    end

    assert_redirected_to project_randomization_scheme_stratification_factor_stratification_factor_options_path(
      assigns(:project), assigns(:randomization_scheme),
      assigns(:stratification_factor)
    )
  end

  test 'should not destroy stratification factor option for published randomization scheme' do
    login(@project_editor)
    assert_difference('StratificationFactorOption.current.count', 0) do
      delete :destroy, project_id: @project,
                       randomization_scheme_id: @published_scheme,
                       stratification_factor_id: @published_stratification_factor,
                       id: @published_stratification_factor_option
    end

    assert_redirected_to project_randomization_scheme_stratification_factor_stratification_factor_option_path(
      assigns(:project), assigns(:randomization_scheme),
      assigns(:stratification_factor), assigns(:stratification_factor_option)
    )
  end
end
