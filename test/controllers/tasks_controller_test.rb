require 'test_helper'

# Tests to make sure project members can view and edit project tasks
class TasksControllerTest < ActionController::TestCase
  setup do
    @task = tasks(:one)
    @project = projects(:one)
  end

  test 'should get index as project editor' do
    login(users(:valid))
    get :index, project_id: @project
    assert_response :success
    assert_not_nil assigns(:tasks)
  end

  test 'should get new as project editor' do
    login(users(:valid))
    get :new, project_id: @project
    assert_response :success
  end

  test 'should create task as project editor' do
    login(users(:valid))
    assert_difference('Task.count') do
      post :create, project_id: @project, task: { completed: @task.completed, description: @task.description, due_date: '02/15/2016', only_unblinded: @task.only_unblinded, window_end_date: '02/10/2016', window_start_date: '02/20/2016' }
    end

    assert_redirected_to [assigns(:project), assigns(:task)]
  end

  test 'should show task as project editor' do
    login(users(:valid))
    get :show, project_id: @project, id: @task
    assert_response :success
  end

  test 'should get edit as project editor' do
    login(users(:valid))
    get :edit, project_id: @project, id: @task
    assert_response :success
  end

  test 'should update task as project editor' do
    login(users(:valid))
    patch :update, project_id: @project, id: @task, task: { completed: @task.completed, description: @task.description, due_date: '02/15/2016', only_unblinded: @task.only_unblinded, window_end_date: '02/10/2016', window_start_date: '02/20/2016' }
    assert_redirected_to [assigns(:project), assigns(:task)]
  end

  test 'should destroy task as project editor' do
    login(users(:valid))
    assert_difference('Task.current.count', -1) do
      delete :destroy, project_id: @project, id: @task
    end

    assert_redirected_to project_tasks_path(assigns(:project))
  end
end
