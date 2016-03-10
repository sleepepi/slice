# frozen_string_literal: true

require 'test_helper'

# Tests to make sure project members can view and edit project tasks
class TasksControllerTest < ActionController::TestCase
  setup do
    @task = tasks(:one)
    @project = projects(:one)
    @project_editor = users(:project_one_editor)
  end

  def task_params
    {
      completed: @task.completed,
      description: @task.description,
      due_date: '02/15/2016',
      only_unblinded: @task.only_unblinded,
      window_end_date: '02/10/2016',
      window_start_date: '02/20/2016'
    }
  end

  test 'should get index as project editor' do
    login(@project_editor)
    get :index, project_id: @project
    assert_response :success
    assert_not_nil assigns(:tasks)
  end

  test 'should get new as project editor' do
    login(@project_editor)
    get :new, project_id: @project
    assert_response :success
  end

  test 'should create task as project editor' do
    login(@project_editor)
    assert_difference('Task.count') do
      post :create, project_id: @project, task: task_params
    end
    assert_redirected_to [@project, Task.last]
  end

  test 'should not create task with blank description' do
    login(@project_editor)
    assert_difference('Task.count', 0) do
      post :create, project_id: @project,
                    task: task_params.merge(description: '')
    end
    assert_template 'new'
    assert_response :success
  end

  test 'should show task as project editor' do
    login(@project_editor)
    get :show, project_id: @project, id: @task
    assert_response :success
  end

  test 'should get edit as project editor' do
    login(@project_editor)
    get :edit, project_id: @project, id: @task
    assert_response :success
  end

  test 'should update task as project editor' do
    login(@project_editor)
    patch :update, project_id: @project, id: @task, task: task_params
    assert_redirected_to [@project, @task]
  end

  test 'should not update task with blank description' do
    login(@project_editor)
    patch :update, project_id: @project, id: @task,
                   task: task_params.merge(description: '')
    assert_template 'edit'
    assert_response :success
  end

  test 'should destroy task as project editor' do
    login(@project_editor)
    assert_difference('Task.current.count', -1) do
      delete :destroy, project_id: @project, id: @task
    end

    assert_redirected_to project_tasks_path(@project)
  end
end
