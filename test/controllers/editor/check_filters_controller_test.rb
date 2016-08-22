# frozen_string_literal: true

require 'test_helper'

# Tests to assure that project editors can add filters to project checks.
class Editor::CheckFiltersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project_editor = users(:project_one_editor)
    @project = projects(:one)
    @check = checks(:one)
    @check_filter = check_filters(:one)
  end

  def check_filter_params
    {
      filter_type: @check_filter.filter_type,
      operator: @check_filter.operator,
      variable_id: @check_filter.variable_id,
      position: @check_filter.position
    }
  end

  test 'should get index' do
    login(@project_editor)
    get editor_project_check_check_filters_path(@project, @check)
    assert_response :success
  end

  test 'should get new' do
    login(@project_editor)
    get new_editor_project_check_check_filter_path(@project, @check)
    assert_response :success
  end

  test 'should create check filter' do
    login(@project_editor)
    assert_difference('CheckFilter.count') do
      post editor_project_check_check_filters_path(@project, @check), params: {
        check_filter: check_filter_params
      }
    end
    assert_redirected_to editor_project_check_check_filter_path(
      @project, @check, CheckFilter.last
    )
  end

  test 'should not create check filter without operator' do
    login(@project_editor)
    assert_difference('CheckFilter.count', 0) do
      post editor_project_check_check_filters_path(@project, @check), params: {
        check_filter: check_filter_params.merge(operator: '')
      }
    end
    assert_template 'new'
    assert_response :success
  end

  test 'should show check filter' do
    login(@project_editor)
    get editor_project_check_check_filter_path(@project, @check, @check_filter)
    assert_response :success
  end

  test 'should get edit' do
    login(@project_editor)
    get edit_editor_project_check_check_filter_path(
      @project, @check, @check_filter
    )
    assert_response :success
  end

  test 'should update check filter' do
    login(@project_editor)
    patch editor_project_check_check_filter_path(
      @project, @check, @check_filter
    ), params: { check_filter: check_filter_params }
    assert_redirected_to editor_project_check_check_filter_path(
      @project, @check, @check_filter
    )
  end

  test 'should not update check filter without operator' do
    login(@project_editor)
    patch editor_project_check_check_filter_path(
      @project, @check, @check_filter
    ), params: { check_filter: check_filter_params.merge(operator: '') }
    assert_template 'edit'
    assert_response :success
  end

  test 'should destroy check filter' do
    login(@project_editor)
    assert_difference('CheckFilter.count', -1) do
      delete editor_project_check_check_filter_path(
        @project, @check, @check_filter
      )
    end
    assert_redirected_to editor_project_check_check_filters_path(
      @project, @check
    )
  end
end
