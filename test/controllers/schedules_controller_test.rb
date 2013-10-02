require 'test_helper'

class SchedulesControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @project = projects(:one)
    @schedule = schedules(:one)
  end

  test "should get index" do
    get :index, project_id: @project
    assert_response :success
    assert_not_nil assigns(:schedules)
  end

  test "should get new" do
    get :new, project_id: @project
    assert_response :success
  end

  test "should create schedule" do
    assert_difference('Schedule.count') do
      post :create, project_id: @project, schedule: { name: 'New Schedule', description: @schedule.description, items: @schedule.items }
    end

    assert_redirected_to project_schedule_path(assigns(:schedule).project, assigns(:schedule))
  end

  test "should not create schedule with non-unique name" do
    assert_difference('Schedule.count', 0) do
      post :create, project_id: @project, schedule: { name: 'Schedule One', description: @schedule.description, items: @schedule.items }
    end

    assert_not_nil assigns(:schedule)
    assert assigns(:schedule).errors.size > 0
    assert_equal ["has already been taken"], assigns(:schedule).errors[:name]
    assert_template 'new'
  end

  test "should show schedule" do
    get :show, id: @schedule, project_id: @project
    assert_response :success
  end

  test "should not show schedule with invalid id" do
    get :show, id: -1, project_id: @project
    assert_redirected_to project_schedules_path(assigns(:project))
  end

  test "should get edit" do
    get :edit, id: @schedule, project_id: @project
    assert_response :success
  end

  test "should update schedule" do
    patch :update, id: @schedule, project_id: @project, schedule: { name: 'Name Updated', description: @schedule.description, items: @schedule.items }
    assert_redirected_to project_schedule_path(assigns(:schedule).project, assigns(:schedule))
  end

  test "should not update schedule with non-unique name" do
    patch :update, id: @schedule, project_id: @project, schedule: { name: 'Schedule Two', description: @schedule.description, items: @schedule.items }
    assert_not_nil assigns(:schedule)
    assert assigns(:schedule).errors.size > 0
    assert_equal ["has already been taken"], assigns(:schedule).errors[:name]
    assert_template 'edit'
  end

  test "should destroy schedule" do
    assert_difference('Schedule.current.count', -1) do
      delete :destroy, id: @schedule, project_id: @project
    end

    assert_redirected_to project_schedules_path(assigns(:project))
  end
end
