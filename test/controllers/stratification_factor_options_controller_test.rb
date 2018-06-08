# frozen_string_literal: true

require "test_helper"

# Tests to assure that project editors can modify stratification factor options.
class StratificationFactorOptionsControllerTest < ActionDispatch::IntegrationTest
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

  test "should get index" do
    login(@project_editor)
    get project_randomization_scheme_stratification_factor_stratification_factor_options_url(
      @project,
      @published_scheme,
      @published_stratification_factor
    )
    assert_response :success
  end

  test "should get new" do
    login(@project_editor)
    get new_project_randomization_scheme_stratification_factor_stratification_factor_option_url(
      @project,
      @published_scheme,
      @published_stratification_factor
    )
    assert_response :success
  end

  test "should create stratification factor option" do
    login(@project_editor)
    assert_difference("StratificationFactorOption.count") do
      post project_randomization_scheme_stratification_factor_stratification_factor_options_url(
        @project,
        @published_scheme,
        @published_stratification_factor
      ), params: {
        stratification_factor_option: { label: "Other", value: 3 }
      }
    end
    assert_redirected_to project_randomization_scheme_stratification_factor_stratification_factor_option_url(
      @project, @published_scheme,
      @published_stratification_factor, StratificationFactorOption.last
    )
  end

  test "should not create stratification factor option without label" do
    login(@project_editor)
    assert_difference("StratificationFactorOption.count", 0) do
      post project_randomization_scheme_stratification_factor_stratification_factor_options_url(
        @project,
        @published_scheme,
        @published_stratification_factor
      ), params: {
        stratification_factor_option: { label: "", value: 3 }
      }
    end
    assert_template "new"
    assert_response :success
  end

  test "should show stratification factor option" do
    login(@project_editor)
    get project_randomization_scheme_stratification_factor_stratification_factor_option_url(
      @project,
      @published_scheme,
      @published_stratification_factor,
      @published_stratification_factor_option
    )
    assert_response :success
  end

  test "should not show stratification factor option with invalid stratification factor" do
    login(@project_editor)
    get project_randomization_scheme_stratification_factor_stratification_factor_option_url(
      @project,
      @published_scheme,
      -1,
      @published_stratification_factor_option
    )
    assert_redirected_to project_randomization_scheme_stratification_factors_url(@project, @published_scheme)
  end

  test "should not show stratification factor option with invalid stratification factor option" do
    login(@project_editor)
    get project_randomization_scheme_stratification_factor_stratification_factor_option_url(
      @project,
      @published_scheme,
      @published_stratification_factor,
      -1
    )
    assert_redirected_to project_randomization_scheme_stratification_factor_stratification_factor_options_url(
      @project, @published_scheme, @published_stratification_factor
    )
  end

  test "should get edit" do
    login(@project_editor)
    get edit_project_randomization_scheme_stratification_factor_stratification_factor_option_url(
      @project,
      @published_scheme,
      @published_stratification_factor,
      @published_stratification_factor_option
    )
    assert_response :success
  end

  test "should update stratification factor option" do
    login(@project_editor)
    patch project_randomization_scheme_stratification_factor_stratification_factor_option_url(
      @project,
      @published_scheme,
      @published_stratification_factor,
      @published_stratification_factor_option
    ), params: {
      stratification_factor_option: { label: "Updated Option", value: 1 }
    }
    assert_redirected_to project_randomization_scheme_stratification_factor_stratification_factor_option_url(
      @project, @published_scheme,
      @published_stratification_factor, @published_stratification_factor_option
    )
  end

  test "should not update stratification factor option with blank label" do
    login(@project_editor)
    patch project_randomization_scheme_stratification_factor_stratification_factor_option_url(
      @project,
      @published_scheme,
      @published_stratification_factor,
      @published_stratification_factor_option
    ), params: {
      stratification_factor_option: { label: "", value: 1 }
    }
    assert_template "edit"
    assert_response :success
  end

  test "should destroy stratification factor option" do
    login(@project_editor)
    assert_difference("StratificationFactorOption.current.count", -1) do
      delete project_randomization_scheme_stratification_factor_stratification_factor_option_url(
        @project,
        @randomization_scheme,
        @stratification_factor,
        @stratification_factor_option
      )
    end
    assert_redirected_to project_randomization_scheme_stratification_factor_stratification_factor_options_url(
      @project,
      @randomization_scheme,
      @stratification_factor
    )
  end

  test "should not destroy stratification factor option for published randomization scheme" do
    login(@project_editor)
    assert_difference("StratificationFactorOption.current.count", 0) do
      delete project_randomization_scheme_stratification_factor_stratification_factor_option_url(
        @project,
        @published_scheme,
        @published_stratification_factor,
        @published_stratification_factor_option
      )
    end
    assert_redirected_to project_randomization_scheme_stratification_factor_stratification_factor_option_url(
      @project,
      @published_scheme,
      @published_stratification_factor,
      @published_stratification_factor_option
    )
  end
end
