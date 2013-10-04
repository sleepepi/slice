require 'test_helper'

class SubjectSchedulesControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @project = projects(:one)
    @subject = subjects(:two)
    @subject_schedule = subject_schedules(:one)
  end

  # test "should get index" do
  #   get :index
  #   assert_response :success
  #   assert_not_nil assigns(:subject_schedules)
  # end

  test "should get new" do
    get :new, project_id: @project, subject_id: @subject
    assert_response :success
  end

  test "should create subject_schedule" do
    assert_difference('SubjectSchedule.count') do
      post :create, project_id: @project, subject_id: @subject, subject_schedule: { schedule_id: @subject_schedule.schedule_id, initial_due_date: "10/15/2013" }
    end

    assert_not_nil assigns(:subject_schedule)
    assert_equal Date.parse("20131015"), assigns(:subject_schedule).initial_due_date

    assert_redirected_to project_subject_path(assigns(:subject).project, assigns(:subject))
  end

  # test "should show subject_schedule" do
  #   get :show, id: @subject_schedule
  #   assert_response :success
  # end

  test "should get edit" do
    get :edit, id: @subject_schedule, project_id: @project, subject_id: @subject
    assert_response :success
  end

  test "should update subject_schedule" do
    patch :update, id: @subject_schedule, project_id: @project, subject_id: @subject, subject_schedule: { schedule_id: @subject_schedule.schedule_id, initial_due_date: "10/20/2013" }

    assert_not_nil assigns(:subject_schedule)
    assert_equal Date.parse("20131020"), assigns(:subject_schedule).initial_due_date

    assert_redirected_to project_subject_path(assigns(:subject).project, assigns(:subject))
  end

  test "should destroy subject_schedule" do
    assert_difference('SubjectSchedule.count', -1) do
      delete :destroy, id: @subject_schedule, project_id: @project, subject_id: @subject
    end

    assert_redirected_to project_subject_path(assigns(:subject).project, assigns(:subject))
  end
end
