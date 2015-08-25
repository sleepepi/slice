require 'test_helper'

class SubjectsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @project = projects(:one)
    @subject = subjects(:one)
  end

  test "should get search for regular user" do
    get :search, project_id: @project, q: 'Code01'
    subjects_json = JSON.parse(response.body)
    assert_equal 'Code01', subjects_json.first['value']
    assert_equal 'Code01', subjects_json.first['subject_code']
    assert_equal 'success', subjects_json.first['status_class']
    assert_equal 'v', subjects_json.first['status']
    assert_response :success
  end

  test "should destroy event and not destroy associated sheets" do
    @subject_event = subject_events(:one)
    assert_difference('SubjectEvent.count', -1) do
      assert_difference('Sheet.current.count', 0) do
        delete :destroy_event, project_id: @project, id: @subject, event_id: @subject_event.event, subject_event_id: @subject_event.id, event_date: @subject_event.event_date_to_param
      end
    end

    assert_not_nil assigns(:project)
    assert_not_nil assigns(:subject)
    assert_not_nil assigns(:event)
    assert_not_nil assigns(:subject_event)

    assert_redirected_to [assigns(:project), assigns(:subject)]
  end

  test "should get timeline" do
    get :timeline, id: @subject, project_id: @project
    assert_response :success
  end

  test "should get comments" do
    get :comments, id: @subject, project_id: @project
    assert_response :success
  end

  test "should get settings" do
    get :settings, id: @subject, project_id: @project
    assert_response :success
  end

  test "should get files" do
    get :files, id: @subject, project_id: @project
    assert_response :success
  end

  test "should show events available to a subject" do
    get :choose_an_event_for_subject, id: @subject, project_id: @project
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:subject)
    assert_response :success
  end

  test "should show designs available to a subject for a specific event" do
    get :choose_date, id: @subject, project_id: @project, event_id: 'event-one'
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:subject)
    assert_not_nil assigns(:event)
    assert_response :success
  end

  test "should not show designs available to a subject for a non-existent event" do
    get :choose_date, id: @subject, project_id: @project, event_id: 'event-does-not-exist'
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:subject)
    assert_nil assigns(:event)
    assert_redirected_to [assigns(:project), assigns(:subject)]
  end

  test "should launch subject event for subject" do
    post :launch_subject_event, id: @subject, project_id: @project, event_id: events(:one), event_date: { month: '2', day: '14', year: '2015' }
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:subject)
    assert_not_nil assigns(:event)
    assert_equal Date.parse("2015-02-14"), assigns(:subject_event).event_date
    assert_redirected_to event_project_subject_path(assigns(:project), assigns(:subject), event_id: assigns(:event), subject_event_id: assigns(:subject_event), event_date: assigns(:subject_event).event_date_to_param)
  end

  test "should not launch subject event for subject with invalid date" do
    post :launch_subject_event, id: @subject, project_id: @project, event_id: events(:one), event_date: { month: '2', day: '30', year: '2015' }
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:subject)
    assert_not_nil assigns(:event)
    assert_nil assigns(:subject_event)
    assert_redirected_to choose_date_project_subject_path(assigns(:project), assigns(:subject), event_id: assigns(:event), event_date: { month: 2, day: 30, year: 2015 })
  end

  test "should get subject event for subject" do
    get :event, id: @subject, project_id: @project, event_id: events(:one), subject_event_id: subject_events(:one), event_date: subject_events(:one).event_date_to_param
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:subject)
    assert_not_nil assigns(:event)
    assert_not_nil assigns(:subject_event)
    assert_response :success
  end

  test "should get edit subject event for subject" do
    get :edit_event, id: @subject, project_id: @project, event_id: events(:one), subject_event_id: subject_events(:one), event_date: subject_events(:one).event_date_to_param
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:subject)
    assert_not_nil assigns(:event)
    assert_not_nil assigns(:subject_event)
    assert_response :success
  end

  test "should update subject event for subject" do
    post :update_event, id: @subject, project_id: @project, event_id: events(:one), subject_event_id: subject_events(:one), event_date: subject_events(:one).event_date_to_param, new_event_date: { month: '12', day: '4', year: '2015' }
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:subject)
    assert_not_nil assigns(:event)
    assert_not_nil assigns(:subject_event)
    assert_equal Date.parse("2015-12-04"), assigns(:subject_event).event_date
    assert_redirected_to event_project_subject_path(assigns(:project), assigns(:subject), event_id: assigns(:event), subject_event_id: assigns(:subject_event), event_date: assigns(:subject_event).event_date_to_param)
  end

  test "should update subject event for subject with invalid date" do
    post :update_event, id: @subject, project_id: @project, event_id: events(:one), subject_event_id: subject_events(:one), event_date: subject_events(:one).event_date_to_param, new_event_date: { month: '12', day: '0', year: '2015' }
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:subject)
    assert_not_nil assigns(:event)
    assert_not_nil assigns(:subject_event)
    assert_equal Date.parse("2015-03-31"), assigns(:subject_event).event_date
    assert_redirected_to edit_event_project_subject_path(assigns(:project), assigns(:subject), event_id: assigns(:event), subject_event_id: assigns(:subject_event), event_date: assigns(:subject_event).event_date_to_param, new_event_date: { month: 12, day: 0, year: 2015 })
  end

  test "should get choose site for new subject" do
    get :choose_site, project_id: @project, subject_code: 'CodeNew'
    assert_not_nil assigns(:project)
    assert_nil assigns(:subject)
    assert_response :success
  end

  test "should redirect to subject when choosing site for existing subject" do
    get :choose_site, project_id: @project, subject_code: 'Code01'
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:subject)
    assert_redirected_to [assigns(:project), assigns(:subject)]
  end

  test "should get index" do
    get :index, project_id: @project
    assert_response :success
    assert_not_nil assigns(:subjects)
  end

  test "should not get index with invalid project" do
    get :index, project_id: -1
    assert_nil assigns(:subjects)
    assert_redirected_to root_path
  end

  test "should get paginated index" do
    get :index, project_id: @project, format: 'js'
    assert_not_nil assigns(:subjects)
    assert_template 'index'
  end

  test "should get new" do
    get :new, project_id: @project
    assert_response :success
  end

  test "should not get new subject with invalid project" do
    get :new, project_id: -1

    assert_nil assigns(:project)
    assert_nil assigns(:subject)

    assert_redirected_to root_path
  end

  test "should create subject" do
    assert_difference('Subject.count') do
      post :create, project_id: @project, subject: { subject_code: 'Code03', acrostic: '', status: @subject.status }, site_id: @subject.site_id
    end

    assert_redirected_to project_subject_path(assigns(:subject).project, assigns(:subject))
  end

  test "should create subject and strip whitespace" do
    assert_difference('Subject.count') do
      post :create, project_id: @project, subject: { subject_code: ' Code04 ', acrostic: '', status: @subject.status }, site_id: @subject.site_id
    end

    assert_equal 'Code04', assigns(:subject).subject_code

    assert_redirected_to project_subject_path(assigns(:subject).project, assigns(:subject))
  end

  test "should not create subject with blank subject code" do
    assert_difference('Subject.count', 0) do
      post :create, project_id: @project, subject: { subject_code: '', acrostic: '', status: @subject.status }, site_id: @subject.site_id
    end

    assert_not_nil assigns(:subject)
    assert assigns(:subject).errors.size > 0
    assert_equal ["can't be blank"], assigns(:subject).errors[:subject_code]
    assert_template 'new'
  end

  test "should not create subject with a subject code that differs only in upper or lower case to an existing subject code" do
    assert_difference('Subject.count', 0) do
      post :create, project_id: @project, subject: { subject_code: 'code01', acrostic: '', status: @subject.status }, site_id: @subject.site_id
    end

    assert_not_nil assigns(:subject)
    assert assigns(:subject).errors.size > 0
    assert_equal ["has already been taken"], assigns(:subject).errors[:subject_code]
    assert_template 'new'
  end

  test "should not create subject for invalid project" do
    assert_difference('Subject.count', 0) do
      post :create, project_id: projects(:four), subject: { subject_code: 'Code03', acrostic: '', status: @subject.status }, site_id: @subject.site_id
    end

    assert_nil assigns(:project)
    assert_nil assigns(:subject)

    assert_redirected_to root_path
  end

  test "should not create subject for site viewer" do
    login(users(:site_one_viewer))
    assert_difference('Subject.count', 0) do
      post :create, project_id: @project, subject: { subject_code: 'Code03', acrostic: '', status: 'valid' }, site_id: sites(:one).id
    end

    assert_nil assigns(:project)
    assert_nil assigns(:subject)

    assert_redirected_to root_path
  end

  test "should create subject for site editor" do
    login(users(:site_one_editor))
    assert_difference('Subject.count') do
      post :create, project_id: @project, subject: { subject_code: 'Code03', acrostic: '', status: 'valid' }, site_id: sites(:one).id
    end

    assert_redirected_to project_subject_path(assigns(:subject).project, assigns(:subject))
  end

  test "should not create subject for site editor for another site" do
    login(users(:site_one_editor))
    assert_difference('Subject.count', 0) do
      post :create, project_id: @project, subject: { subject_code: 'Code03', acrostic: '', status: 'valid' }, site_id: sites(:two).id
    end

    assert_not_nil assigns(:project)
    assert_not_nil assigns(:subject)

    assert_not_nil assigns(:subject)
    assert assigns(:subject).errors.size > 0
    assert_equal ["can't be blank"], assigns(:subject).errors[:site_id]
    assert_template 'new'
  end

  test "should show subject" do
    get :show, id: @subject, project_id: @project
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:subject)
    assert_response :success
  end

  test "should show subject to site user" do
    login(users(:site_one_viewer))
    get :show, id: @subject, project_id: @project
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:subject)
    assert_response :success
  end

  test "should not show invalid subject" do
    get :show, id: -1, project_id: @project
    assert_not_nil assigns(:project)
    assert_nil assigns(:subject)
    assert_redirected_to project_subjects_path
  end

  test "should not show subject with invalid project" do
    get :show, id: @subject, project_id: -1

    assert_nil assigns(:project)
    assert_nil assigns(:subject)

    assert_redirected_to root_path
  end

  test "should not show subject on different site to site user" do
    login(users(:site_one_viewer))
    get :show, id: subjects(:three), project_id: @project
    assert_nil assigns(:subject)
    assert_redirected_to project_subjects_path
  end

  test "should get edit" do
    get :edit, id: @subject, project_id: @project
    assert_response :success
  end

  test "should get edit for site editor" do
    login(users(:site_one_editor))
    get :edit, id: @subject, project_id: @project
    assert_response :success
  end

  test "should not get edit for site editor for another site" do
    login(users(:site_one_editor))
    get :edit, id: subjects(:three), project_id: @project
    assert_redirected_to project_subjects_path
  end

  test "should not get edit for site viewer" do
    login(users(:site_one_viewer))
    get :edit, id: @subject, project_id: @project
    assert_redirected_to root_path
  end

  test "should not get edit for invalid subject" do
    get :edit, id: -1, project_id: @project

    assert_not_nil assigns(:project)
    assert_nil assigns(:subject)

    assert_redirected_to project_subjects_path
  end

  test "should not get edit with invalid project" do
    get :edit, id: @subject, project_id: -1

    assert_nil assigns(:project)
    assert_nil assigns(:subject)

    assert_redirected_to root_path
  end

  test "should update subject" do
    put :update, id: @subject, project_id: @project, subject: { subject_code: @subject.subject_code, acrostic: '', status: @subject.status }, site_id: @subject.site_id
    assert_redirected_to project_subject_path(assigns(:subject).project, assigns(:subject))
  end

  test "should update subject with blank subject code" do
    put :update, id: @subject, project_id: @project, subject: { subject_code: '', acrostic: '', status: @subject.status }, site_id: @subject.site_id
    assert_not_nil assigns(:subject)
    assert assigns(:subject).errors.size > 0
    assert_equal ["can't be blank"], assigns(:subject).errors[:subject_code]
    assert_template 'edit'
  end

  test "should not update invalid subject" do
    put :update, id: -1, project_id: @project, subject: { subject_code: @subject.subject_code, acrostic: '', status: @subject.status }, site_id: @subject.site_id
    assert_nil assigns(:subject)
    assert_redirected_to project_subjects_path
  end

  test "should not update subject with invalid project" do
    put :update, id: @subject, project_id: -1, subject: { subject_code: @subject.subject_code, acrostic: '', status: @subject.status }, site_id: @subject.site_id

    assert_nil assigns(:subject)
    assert_nil assigns(:project)

    assert_redirected_to root_path
  end

  test "should not update subject for site editor for another site" do
    login(users(:site_one_editor))
    put :update, id: subjects(:three), project_id: @project, subject: { subject_code: "New Subject Code", acrostic: '', status: @subject.status }, site_id: sites(:one)

    assert_not_nil assigns(:project)
    assert_nil assigns(:subject)

    assert_redirected_to project_subjects_path
  end

  test "should destroy subject" do
    assert_difference('Subject.current.count', -1) do
      delete :destroy, id: @subject, project_id: @project
    end

    assert_not_nil assigns(:subject)
    assert_not_nil assigns(:project)

    assert_redirected_to project_subjects_path
  end

  test "should not destroy subject with invalid project" do
    assert_difference('Subject.current.count', 0) do
      delete :destroy, id: @subject, project_id: -1
    end

    assert_nil assigns(:project)
    assert_nil assigns(:subject)

    assert_redirected_to root_path
  end
end
