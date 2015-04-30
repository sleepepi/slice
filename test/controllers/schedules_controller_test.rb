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

  test "should show schedule" do
    get :show, id: @schedule, project_id: @project
    assert_response :success
  end

  test "should not show schedule with invalid id" do
    get :show, id: -1, project_id: @project
    assert_redirected_to project_schedules_path(assigns(:project))
  end
end
