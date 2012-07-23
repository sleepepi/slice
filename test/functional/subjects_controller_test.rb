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
      post :create, subject: { project_id: @subject.project_id, subject_code: 'Code03', validated: @subject.validated }, site_id: @subject.site_id
    end

    assert_redirected_to subject_path(assigns(:subject))
  end

  test "should not create subject for invalid project" do
    assert_difference('Subject.count', 0) do
      post :create, subject: { project_id: projects(:four).id, subject_code: 'Code03', validated: @subject.validated }, site_id: @subject.site_id
    end

    assert_not_nil assigns(:subject)
    assert_equal ["can't be blank"], assigns(:subject).errors[:project_id]
    assert_template 'new'
    assert_response :success
  end

  test "should not create subject for site user" do
    login(users(:site_one_user))
    assert_difference('Subject.count', 0) do
      post :create, subject: { project_id: projects(:one).id, subject_code: 'Code03', validated: true }, site_id: sites(:one).id
    end

    assert_not_nil assigns(:subject)
    assert_equal ["can't be blank"], assigns(:subject).errors[:project_id]
    assert_template 'new'
    assert_response :success
  end

  test "should show subject" do
    get :show, id: @subject
    assert_not_nil assigns(:subject)
    assert_response :success
  end

  test "should show subject to site user" do
    login(users(:site_one_user))
    get :show, id: @subject
    assert_not_nil assigns(:subject)
    assert_response :success
  end

  test "should not show invalid subject" do
    get :show, id: -1
    assert_nil assigns(:subject)
    assert_redirected_to subjects_path
  end

  test "should not show subject on different site to site user" do
    login(users(:site_one_user))
    get :show, id: subjects(:three)
    assert_nil assigns(:subject)
    assert_redirected_to subjects_path
  end

  test "should get edit" do
    get :edit, id: @subject
    assert_response :success
  end

  test "should update subject" do
    put :update, id: @subject, subject: { project_id: @subject.project_id, subject_code: @subject.subject_code, validated: @subject.validated }, site_id: @subject.site_id
    assert_redirected_to subject_path(assigns(:subject))
  end

  test "should update subject with blank subject code" do
    put :update, id: @subject, subject: { project_id: @subject.project_id, subject_code: '', validated: @subject.validated }, site_id: @subject.site_id
    assert_not_nil assigns(:subject)
    assert assigns(:subject).errors.size > 0
    assert_equal ["can't be blank"], assigns(:subject).errors[:subject_code]
    assert_template 'edit'
  end

  test "should not update invalid subject" do
    put :update, id: -1, subject: { project_id: @subject.project_id, subject_code: @subject.subject_code, validated: @subject.validated }, site_id: @subject.site_id
    assert_nil assigns(:subject)
    assert_redirected_to subjects_path
  end

  test "should destroy subject" do
    assert_difference('Subject.current.count', -1) do
      delete :destroy, id: @subject
    end

    assert_redirected_to subjects_path
  end
end
