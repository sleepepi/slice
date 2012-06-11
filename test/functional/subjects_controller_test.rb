require 'test_helper'

class SubjectsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @subject = subjects(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:subjects)
  end

  test "should get paginated index" do
    get :index, format: 'js'
    assert_not_nil assigns(:subjects)
    assert_template 'index'
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create subject" do
    assert_difference('Subject.count') do
      post :create, subject: { project_id: @subject.project_id, subject_code: 'Code03' }, site_id: @subject.site_id
    end

    assert_redirected_to subject_path(assigns(:subject))
  end

  test "should not create subject for invalid project" do
    assert_difference('Subject.count', 0) do
      post :create, subject: { project_id: projects(:four), subject_code: 'Code03' }, site_id: @subject.site_id
    end

    assert_not_nil assigns(:subject)
    assert_equal ["can't be blank"], assigns(:subject).errors[:project_id]
    assert_template 'new'
    assert_response :success
  end

  test "should show subject" do
    get :show, id: @subject
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @subject
    assert_response :success
  end

  test "should update subject" do
    put :update, id: @subject, subject: { project_id: @subject.project_id, subject_code: @subject.subject_code }, site_id: @subject.site_id
    assert_redirected_to subject_path(assigns(:subject))
  end

  test "should destroy subject" do
    assert_difference('Subject.current.count', -1) do
      delete :destroy, id: @subject
    end

    assert_redirected_to subjects_path
  end
end
