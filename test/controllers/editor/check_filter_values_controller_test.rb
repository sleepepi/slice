# frozen_string_literal: true

require 'test_helper'

# Tests to assure that project editors can specify filter values.
class Editor::CheckFilterValuesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project_editor = users(:project_one_editor)
    @project = projects(:one)
    @check = checks(:one)
    @check_filter = check_filters(:one)
    @check_filter_value = check_filter_values(:one)
  end

  def check_filter_value_params
    {
      value: @check_filter_value.value
    }
  end

  test 'should get index' do
    login(@project_editor)
    get editor_project_check_check_filter_check_filter_values_path(
      @project, @check, @check_filter
    )
    assert_response :success
  end

  test 'should get new' do
    login(@project_editor)
    get new_editor_project_check_check_filter_check_filter_value_path(
      @project, @check, @check_filter
    )
    assert_response :success
  end

  test 'should create check filter value' do
    login(@project_editor)
    assert_difference('CheckFilterValue.count') do
      post editor_project_check_check_filter_check_filter_values_path(@project, @check, @check_filter), params: {
        check_filter_value: check_filter_value_params
      }
    end
    assert_redirected_to editor_project_check_check_filter_check_filter_value_path(
      @project, @check, @check_filter, CheckFilterValue.last
    )
  end

  test 'should not create check filter value with blank value' do
    login(@project_editor)
    assert_difference('CheckFilterValue.count', 0) do
      post editor_project_check_check_filter_check_filter_values_path(@project, @check, @check_filter), params: {
        check_filter_value: check_filter_value_params.merge(value: '')
      }
    end
    assert_template 'new'
    assert_response :success
  end

  test 'should show check filter value' do
    login(@project_editor)
    get editor_project_check_check_filter_check_filter_value_path(
      @project, @check, @check_filter, @check_filter_value
    )
    assert_response :success
  end

  test 'should get edit' do
    login(@project_editor)
    get edit_editor_project_check_check_filter_check_filter_value_path(
      @project, @check, @check_filter, @check_filter_value
    )
    assert_response :success
  end

  test 'should update check filter value' do
    login(@project_editor)
    patch editor_project_check_check_filter_check_filter_value_path(@project, @check, @check_filter, @check_filter_value), params: {
      check_filter_value: check_filter_value_params
    }
    assert_redirected_to editor_project_check_check_filter_check_filter_value_path(
      @project, @check, @check_filter, @check_filter_value
    )
  end

  test 'should not update check filter value with blank value' do
    login(@project_editor)
    patch editor_project_check_check_filter_check_filter_value_path(@project, @check, @check_filter, @check_filter_value), params: {
      check_filter_value: check_filter_value_params.merge(value: '')
    }
    assert_template 'edit'
    assert_response :success
  end

  test 'should destroy check filter value' do
    login(@project_editor)
    assert_difference('CheckFilterValue.count', -1) do
      delete editor_project_check_check_filter_check_filter_value_path(
        @project, @check, @check_filter, @check_filter_value
      )
    end
    assert_redirected_to editor_project_check_check_filter_check_filter_values_path(
      @project, @check, @check_filter
    )
  end
end
