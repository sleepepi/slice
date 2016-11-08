# frozen_string_literal: true

require 'test_helper'

# Tests to assure that project editors can create and update grid variables.
class Editor::GridVariablesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @grid_variable = grid_variables(:grid_change_options)
    @project_editor = users(:project_one_editor)
    @project = projects(:one)
  end

  def grid_variable_params
    {
      parent_variable_id: @grid_variable.parent_variable_id,
      child_variable_id: @grid_variable.child_variable_id,
      position: @grid_variable.position
    }
  end

  test 'should get index' do
    login(@project_editor)
    get editor_project_grid_variables_path(@project)
    assert_response :success
  end

  test 'should get new' do
    login(@project_editor)
    get new_editor_project_grid_variable_path(@project)
    assert_response :success
  end

  test 'should create grid variable' do
    login(@project_editor)
    assert_difference('GridVariable.count') do
      post editor_project_grid_variables_path(@project), params: {
        grid_variable: grid_variable_params.merge(child_variable_id: variables(:one).id, position: 8)
      }
    end
    assert_redirected_to editor_project_grid_variable_path(@project, GridVariable.last)
  end

  test 'should show grid variable' do
    login(@project_editor)
    get editor_project_grid_variable_path(@project, @grid_variable)
    assert_response :success
  end

  test 'should get edit' do
    login(@project_editor)
    get edit_editor_project_grid_variable_path(@project, @grid_variable)
    assert_response :success
  end

  test 'should update grid variable' do
    login(@project_editor)
    patch editor_project_grid_variable_path(@project, @grid_variable), params: {
      grid_variable: grid_variable_params
    }
    assert_redirected_to editor_project_grid_variable_path(@project, @grid_variable)
  end

  test 'should destroy grid variable' do
    login(@project_editor)
    assert_difference('GridVariable.count', -1) do
      delete editor_project_grid_variable_path(@project, @grid_variable)
    end
    assert_redirected_to editor_project_grid_variables_path(@project)
  end
end
