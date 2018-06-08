# frozen_string_literal: true

require "test_helper"

# Allows project editors to modify stratification factors for randomization
# schemes.
class StratificationFactorsControllerTest < ActionDispatch::IntegrationTest
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

  test "should get index" do
    login(@project_editor)
    get project_randomization_scheme_stratification_factors_url(
      @project, @randomization_scheme
    )
    assert_response :success
  end

  test "should get new" do
    login(@project_editor)
    get new_project_randomization_scheme_stratification_factor_url(
      @project, @randomization_scheme
    )
    assert_response :success
  end

  test "should not get new for published randomization scheme" do
    login(@project_editor)
    get new_project_randomization_scheme_stratification_factor_url(
      @project, @published_scheme
    )
    assert_redirected_to(
      project_randomization_scheme_stratification_factors_url(assigns(:project), assigns(:randomization_scheme))
    )
  end

  test "should create stratification factor" do
    login(@project_editor)
    assert_difference("StratificationFactor.count") do
      post project_randomization_scheme_stratification_factors_url(
        @project, @randomization_scheme
      ), params: {
        stratification_factor: sf_params.merge(name: "New Stratification Factor")
      }
    end
    assert_redirected_to(
      project_randomization_scheme_stratification_factor_url(
        @project, @randomization_scheme, StratificationFactor.last
      )
    )
  end

  test "should not create stratification factor with blank name" do
    login(@project_editor)
    assert_difference("StratificationFactor.count", 0) do
      post project_randomization_scheme_stratification_factors_url(
        @project, @randomization_scheme
      ), params: {
        stratification_factor: sf_params.merge(name: "")
      }
    end
    assert_template "new"
    assert_response :success
  end

  test "should not create stratification factor for published randomization scheme" do
    login(@project_editor)
    assert_difference("StratificationFactor.count", 0) do
      post project_randomization_scheme_stratification_factors_url(
        @project, @published_scheme
      ), params: {
        stratification_factor: sf_params.merge(name: "New Stratification Factor")
      }
    end
    assert_redirected_to(
      project_randomization_scheme_stratification_factors_url(assigns(:project), assigns(:randomization_scheme))
    )
  end

  test "should show stratification factor" do
    login(@project_editor)
    get project_randomization_scheme_stratification_factor_url(
      @project, @randomization_scheme, @stratification_factor
    )
    assert_response :success
  end

  test "should not show stratification factor with invalid randomization scheme" do
    login(@project_editor)
    get project_randomization_scheme_stratification_factor_url(
      @project, -1, @stratification_factor
    )
    assert_redirected_to project_randomization_schemes_url(@project)
  end

  test "should not show stratification factor with invalid stratification factor" do
    login(@project_editor)
    get project_randomization_scheme_stratification_factor_url(
      @project, @randomization_scheme, -1
    )
    assert_redirected_to project_randomization_scheme_stratification_factors_url(@project, @randomization_scheme)
  end

  test "should get edit" do
    login(@project_editor)
    get edit_project_randomization_scheme_stratification_factor_url(
      @project, @randomization_scheme, @stratification_factor
    )
    assert_response :success
  end

  test "should not get edit for published randomization scheme" do
    login(@project_editor)
    get edit_project_randomization_scheme_stratification_factor_url(
      @project, @published_scheme, @published_stratification_factor
    )
    assert_redirected_to(
      project_randomization_scheme_stratification_factor_url(
        @project, @published_scheme, @published_stratification_factor
      )
    )
  end

  test "should update stratification factor" do
    login(@project_editor)
    patch project_randomization_scheme_stratification_factor_url(
      @project, @randomization_scheme, @stratification_factor
    ), params: {
      stratification_factor: sf_params.merge(name: "Updated Stratification Factor")
    }
    assert_redirected_to(
      project_randomization_scheme_stratification_factor_url(
        assigns(:project), assigns(:randomization_scheme), assigns(:stratification_factor)
      )
    )
  end

  test "should not update stratification factor with blank name" do
    login(@project_editor)
    patch project_randomization_scheme_stratification_factor_url(
      @project, @randomization_scheme, @stratification_factor
    ), params: {
      stratification_factor: sf_params.merge(name: "")
    }
    assert_template "edit"
    assert_response :success
  end

  test "should not update stratification factor for published randomization scheme" do
    login(@project_editor)
    patch project_randomization_scheme_stratification_factor_url(
      @project, @published_scheme, @published_stratification_factor
    ), params: {
      stratification_factor: sf_params.merge(name: "Updated Stratification Factor")
    }
    assert_equal "Gender", assigns(:stratification_factor).name
    assert_redirected_to(
      project_randomization_scheme_stratification_factor_url(
        assigns(:project), assigns(:randomization_scheme), assigns(:stratification_factor)
      )
    )
  end

  test "should destroy stratification factor" do
    login(@project_editor)
    assert_difference("StratificationFactor.current.count", -1) do
      delete project_randomization_scheme_stratification_factor_url(
        @project, @randomization_scheme, @stratification_factor
      )
    end
    assert_redirected_to(
      project_randomization_scheme_stratification_factors_url(
        @project, @randomization_scheme
      )
    )
  end

  test "should not destroy stratification factor for published randomization scheme" do
    login(@project_editor)
    assert_difference("StratificationFactor.current.count", 0) do
      delete project_randomization_scheme_stratification_factor_url(
        @project, @published_scheme, @published_stratification_factor
      )
    end
    assert_redirected_to(
      project_randomization_scheme_stratification_factor_url(
        @project, @published_scheme, @published_stratification_factor
      )
    )
  end
end
