# frozen_string_literal: true

require "test_helper"

# Tests to make sure project members can view and edit project tasks.
class TasksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @task = tasks(:one)
    @project = projects(:one)
    @project_editor = users(:project_one_editor)
  end

  def task_params
    {
      completed: @task.completed,
      description: @task.description,
      due_date: "02/15/2016",
      only_unblinded: @task.only_unblinded,
      window_end_date: "02/10/2016",
      window_start_date: "02/20/2016"
    }
  end

  test "should get index as project editor" do
    login(@project_editor)
    get project_tasks_url(@project)
    assert_response :success
  end

  test "should get new as project editor" do
    login(@project_editor)
    get new_project_task_url(@project)
    assert_response :success
  end

  test "should create task as project editor" do
    login(@project_editor)
    assert_difference("Task.count") do
      post project_tasks_url(@project), params: { task: task_params }
    end
    assert_redirected_to [@project, Task.last]
  end

  test "should not create task with blank description" do
    login(@project_editor)
    assert_difference("Task.count", 0) do
      post project_tasks_url(@project), params: {
        task: task_params.merge(description: "")
      }
    end
    assert_template "new"
    assert_response :success
  end

  test "should show task as project editor" do
    login(@project_editor)
    get project_task_url(@project, @task)
    assert_response :success
  end

  test "should get edit as project editor" do
    login(@project_editor)
    get edit_project_task_url(@project, @task)
    assert_response :success
  end

  test "should update task as project editor" do
    login(@project_editor)
    patch project_task_url(@project, @task), params: {
      task: task_params
    }
    assert_redirected_to [@project, @task]
  end

  test "should not update task with blank description" do
    login(@project_editor)
    patch project_task_url(@project, @task), params: {
      task: task_params.merge(description: "")
    }
    assert_template "edit"
    assert_response :success
  end

  test "should destroy task as project editor" do
    login(@project_editor)
    assert_difference("Task.current.count", -1) do
      delete project_task_url(@project, @task)
    end
    assert_redirected_to project_tasks_url(@project)
  end
end
