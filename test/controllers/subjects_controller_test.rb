# frozen_string_literal: true

require 'test_helper'

# Tests to assure that project and site editors can create and modify subjects.
class SubjectsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @project = projects(:one)
    @subject = subjects(:one)
    @project_editor = users(:project_one_editor)
    @project_viewer = users(:project_one_viewer)
    @site_editor = users(:site_one_editor)
    @site_viewer = users(:site_one_viewer)
  end

  test 'should get data entry as site editor' do
    login(users(:site_one_editor))
    get :data_entry, id: @subject, project_id: @project
    assert_response :success
  end

  test 'should not get data entry as site viewer' do
    login(users(:site_one_viewer))
    get :data_entry, id: @subject, project_id: @project
    assert_redirected_to root_path
  end

  test 'should get new data entry as site editor' do
    login(users(:site_one_editor))
    get :new_data_entry, id: @subject, project_id: @project, design_id: designs(:all_variable_types)
    assert_not_nil assigns(:sheet)
    assert_equal designs(:all_variable_types), assigns(:sheet).design
    assert_response :success
  end

  test 'should not get new data entry as site viewer' do
    login(users(:site_one_viewer))
    get :new_data_entry, id: @subject, project_id: @project, design_id: designs(:all_variable_types)
    assert_redirected_to root_path
  end

  test 'should not get data entry new with invalid design' do
    login(users(:site_one_editor))
    get :new_data_entry, id: @subject, project_id: @project, design_id: -1
    assert_redirected_to data_entry_project_subject_path(assigns(:project), assigns(:subject))
  end

  test 'should set sheet as missing on subject event as site editor' do
    login(users(:site_one_editor))
    assert_difference('Sheet.current.where(missing: true).count', 1) do
      post :set_sheet_as_missing, id: @subject, project_id: @project, design_id: designs(:all_variable_types),
                                  subject_event_id: subject_events(:one)
    end
    assert_redirected_to event_project_subject_path(
      assigns(:project),
      assigns(:subject),
      event_id: assigns(:sheet).subject_event.event,
      subject_event_id: assigns(:sheet).subject_event,
      event_date: assigns(:sheet).subject_event.event_date_to_param
    )
  end

  test 'should get send url as site editor' do
    login(@site_editor)
    get :send_url, project_id: @project, id: @subject
    assert_response :success
  end

  test 'should set sheet as shareable as site editor' do
    login(@site_editor)
    assert_difference('Sheet.count') do
      post :set_sheet_as_shareable, project_id: @project, id: @subject,
                                    design_id: designs(:sections_and_variables),
                                    subject_event_id: subject_events(:one)
    end
    assert_redirected_to [@project, Sheet.last]
  end

  test 'should get search as project editor' do
    login(@project_editor)
    get :search, project_id: @project, q: 'Code01'
    subjects_json = JSON.parse(response.body)
    assert_equal 'Code01', subjects_json.first['value']
    assert_equal 'Code01', subjects_json.first['subject_code']
    assert_response :success
  end

  test 'should get search as project viewer' do
    login(@project_viewer)
    get :search, project_id: @project, q: 'Code01'
    subjects_json = JSON.parse(response.body)
    assert_equal 'Code01', subjects_json.first['value']
    assert_equal 'Code01', subjects_json.first['subject_code']
    assert_response :success
  end

  test 'should search for new subject as project editor' do
    login(@project_editor)
    get :search, project_id: @project, q: 'NewCode'
    subjects_json = JSON.parse(response.body)
    assert_equal 'NewCode', subjects_json.first['value']
    assert_equal 'NewCode', subjects_json.first['subject_code']
    assert_equal 'NEW', subjects_json.first['status']
    assert_response :success
  end

  test 'should not search for new subject as project viewer' do
    login(@project_viewer)
    get :search, project_id: @project, q: 'NewCode'
    subjects_json = JSON.parse(response.body)
    assert_nil subjects_json.first
    assert_response :success
  end

  test 'should destroy event and not destroy associated sheets' do
    @subject_event = subject_events(:one)
    assert_difference('SubjectEvent.count', -1) do
      assert_difference('Sheet.current.count', 0) do
        delete :destroy_event, project_id: @project, id: @subject, event_id: @subject_event.event,
                               subject_event_id: @subject_event.id, event_date: @subject_event.event_date_to_param
      end
    end

    assert_not_nil assigns(:project)
    assert_not_nil assigns(:subject)
    assert_not_nil assigns(:event)
    assert_not_nil assigns(:subject_event)
    assert_redirected_to [assigns(:project), assigns(:subject)]
  end

  test 'should get events as project editor' do
    get :events, project_id: @project, id: @subject
    assert_response :success
  end

  test 'should get events as project viewer' do
    login(users(:associated))
    get :events, project_id: @project, id: @subject
    assert_response :success
  end

  test 'should get sheets as project editor' do
    get :sheets, project_id: @project, id: @subject
    assert_response :success
  end

  test 'should get sheets as project viewer' do
    login(users(:associated))
    get :sheets, project_id: @project, id: @subject
    assert_response :success
  end

  test 'should get timeline as project editor' do
    get :timeline, project_id: @project, id: @subject
    assert_response :success
  end

  test 'should get timeline as project viewer' do
    login(users(:associated))
    get :timeline, project_id: @project, id: @subject
    assert_response :success
  end

  test 'should get comments as project editor' do
    get :comments, project_id: @project, id: @subject
    assert_response :success
  end

  test 'should get comments as project viewer' do
    login(users(:associated))
    get :comments, project_id: @project, id: @subject
    assert_response :success
  end

  test 'should get settings as project editor' do
    get :settings, project_id: @project, id: @subject
    assert_response :success
  end

  test 'should get settings as project viewer' do
    login(users(:associated))
    get :settings, project_id: @project, id: @subject
    assert_response :success
  end

  test 'should get files as project editor' do
    get :files, project_id: @project, id: @subject
    assert_response :success
  end

  test 'should get files as project viewer' do
    login(users(:associated))
    get :files, project_id: @project, id: @subject
    assert_response :success
  end

  test 'should get adverse events as project editor' do
    get :adverse_events, project_id: @project, id: @subject
    assert_response :success
  end

  test 'should get adverse events as project viewer' do
    login(users(:associated))
    get :adverse_events, project_id: @project, id: @subject
    assert_response :success
  end

  test 'should show events available to a subject' do
    get :choose_an_event_for_subject, project_id: @project, id: @subject
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:subject)
    assert_response :success
  end

  test 'should show designs available to a subject for a specific event' do
    get :choose_date, project_id: @project, id: @subject, event_id: 'event-one'
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:subject)
    assert_not_nil assigns(:event)
    assert_response :success
  end

  test 'should not show designs available to a subject for a non-existent event' do
    get :choose_date, project_id: @project, id: @subject, event_id: 'event-does-not-exist'
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:subject)
    assert_nil assigns(:event)
    assert_redirected_to [assigns(:project), assigns(:subject)]
  end

  test 'should launch subject event for subject' do
    post :launch_subject_event, project_id: @project, id: @subject, event_id: events(:one),
                                subject_event: { event_date: '02/14/2015' }
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:subject)
    assert_not_nil assigns(:event)
    assert_equal Date.parse('2015-02-14'), assigns(:subject_event).event_date
    assert_redirected_to event_project_subject_path(
      assigns(:project),
      assigns(:subject),
      event_id: assigns(:event),
      subject_event_id: assigns(:subject_event),
      event_date: assigns(:subject_event).event_date_to_param
    )
  end

  test 'should not launch subject event for subject with invalid event' do
    post :launch_subject_event, project_id: @project, id: @subject, event_id: -1,
                                subject_event: { event_date: '02/14/2015' }
    assert_redirected_to [@project, @subject]
  end

  test 'should not launch subject event for subject with invalid date' do
    post :launch_subject_event, project_id: @project, id: @subject, event_id: events(:one),
                                subject_event: { event_date: '02/30/2015' }
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:subject)
    assert_not_nil assigns(:event)
    assert_not_nil assigns(:subject_event)
    assert_template 'choose_date'
    assert_response :success
  end

  test 'should get subject event for subject' do
    get :event, project_id: @project, id: @subject, event_id: events(:one),
                subject_event_id: subject_events(:one), event_date: subject_events(:one).event_date_to_param
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:subject)
    assert_not_nil assigns(:event)
    assert_not_nil assigns(:subject_event)
    assert_response :success
  end

  test 'should get edit subject event for subject' do
    get :edit_event, project_id: @project, id: @subject, event_id: events(:one),
                     subject_event_id: subject_events(:one), event_date: subject_events(:one).event_date_to_param
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:subject)
    assert_not_nil assigns(:event)
    assert_not_nil assigns(:subject_event)
    assert_response :success
  end

  test 'should update subject event for subject' do
    post :update_event, project_id: @project, id: @subject, event_id: events(:one),
                        subject_event_id: subject_events(:one), subject_event: { event_date: '12/4/2015' }
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:subject)
    assert_not_nil assigns(:event)
    assert_not_nil assigns(:subject_event)
    assert_equal Date.parse('2015-12-04'), assigns(:subject_event).event_date
    assert_redirected_to event_project_subject_path(
      assigns(:project),
      assigns(:subject),
      event_id: assigns(:event),
      subject_event_id: assigns(:subject_event),
      event_date: assigns(:subject_event).event_date_to_param
    )
  end

  test 'should not update subject event for subject with invalid date' do
    post :update_event, project_id: @project, id: @subject, event_id: events(:one),
                        subject_event_id: subject_events(:one), subject_event: { event_date: '12/0/2015' }
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:subject)
    assert_not_nil assigns(:event)
    assert_not_nil assigns(:subject_event)
    assert_template 'edit_event'
    assert_response :success
  end

  test 'should get choose site for new subject as project editor' do
    get :choose_site, project_id: @project, subject_code: 'CodeNew'
    assert_not_nil assigns(:project)
    assert_nil assigns(:subject)
    assert_response :success
  end

  test 'should redirect to subject when choosing site for existing subject as project editor' do
    get :choose_site, project_id: @project, subject_code: 'Code01'
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:subject)
    assert_redirected_to [assigns(:project), assigns(:subject)]
  end

  test 'should redirect to subject when choosing site for existing subject as project viewer' do
    login(users(:associated))
    get :choose_site, project_id: @project, subject_code: 'Code01'
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:subject)
    assert_redirected_to [assigns(:project), assigns(:subject)]
  end

  test 'should redirect to project when choosing site for non-existent subject as project viewer' do
    login(users(:associated))
    get :choose_site, project_id: @project, subject_code: 'CodeNew'
    assert_not_nil assigns(:project)
    assert_nil assigns(:subject)
    assert_redirected_to assigns(:project)
  end

  test 'should get index' do
    get :index, project_id: @project
    assert_response :success
  end

  test 'should get index with event' do
    get :index, project_id: @project, event_id: events(:one).id
    assert_response :success
  end

  test 'should get index without event' do
    get :index, project_id: @project, without_event_id: events(:one).id
    assert_response :success
  end

  test 'should get index with design on event' do
    get :index, project_id: @project, on_event_design_id: designs(:one).id, event_id: events(:one).id
    assert_response :success
  end

  test 'should get index with design not on event' do
    get :index, project_id: @project, not_on_event_design_id: designs(:one).id, event_id: events(:one).id
    assert_response :success
  end

  test 'should not get index with invalid project' do
    get :index, project_id: -1
    assert_nil assigns(:subjects)
    assert_redirected_to root_path
  end

  test 'should get paginated index' do
    get :index, project_id: @project, format: 'js'
    assert_not_nil assigns(:subjects)
    assert_template 'index'
  end

  test 'should get new' do
    get :new, project_id: @project
    assert_response :success
  end

  test 'should not get new subject with invalid project' do
    get :new, project_id: -1

    assert_nil assigns(:project)
    assert_nil assigns(:subject)

    assert_redirected_to root_path
  end

  test 'should create subject and strip whitespace' do
    assert_difference('Subject.count') do
      post :create, project_id: @project, subject: { subject_code: ' Code04 ' }, site_id: @subject.site_id
    end
    assert_equal 'Code04', assigns(:subject).subject_code
    assert_redirected_to project_subject_path(assigns(:subject).project, assigns(:subject))
  end

  test 'should create subject with valid subject code' do
    assert_difference('Subject.count') do
      post :create, project_id: @project, subject: { subject_code: 'S100' }, site_id: sites(:site_with_subject_regex)
    end

    assert_redirected_to project_subject_path(assigns(:subject).project, assigns(:subject))
  end

  test 'should not create subject with invalid subject code format' do
    assert_difference('Subject.count', 0) do
      post :create, project_id: @project, subject: { subject_code: 'S100a' }, site_id: sites(:site_with_subject_regex)
    end

    assert_not_nil assigns(:subject)
    assert assigns(:subject).errors.size > 0
    assert_equal ['Subject Code must be in the following format: S1[0-9][0-9]'], assigns(:subject).errors[:base]
    assert_template 'new'
  end

  test 'should not create subject with blank subject code' do
    assert_difference('Subject.count', 0) do
      post :create, project_id: @project, subject: { subject_code: '' }, site_id: @subject.site_id
    end

    assert_not_nil assigns(:subject)
    assert assigns(:subject).errors.size > 0
    assert_equal ["can't be blank"], assigns(:subject).errors[:subject_code]
    assert_template 'new'
  end

  test 'should not create subject with a subject code that differs in case to an existing subject code' do
    assert_difference('Subject.count', 0) do
      post :create, project_id: @project, subject: { subject_code: 'code01' }, site_id: @subject.site_id
    end

    assert_not_nil assigns(:subject)
    assert assigns(:subject).errors.size > 0
    assert_equal ['has already been taken'], assigns(:subject).errors[:subject_code]
    assert_template 'new'
  end

  test 'should not create subject for invalid project' do
    assert_difference('Subject.count', 0) do
      post :create, project_id: projects(:four), subject: { subject_code: 'Code04' }, site_id: @subject.site_id
    end

    assert_nil assigns(:project)
    assert_nil assigns(:subject)

    assert_redirected_to root_path
  end

  test 'should not create subject for site viewer' do
    login(users(:site_one_viewer))
    assert_difference('Subject.count', 0) do
      post :create, project_id: @project, subject: { subject_code: 'Code04' }, site_id: sites(:one).id
    end

    assert_nil assigns(:project)
    assert_nil assigns(:subject)

    assert_redirected_to root_path
  end

  test 'should create subject for site editor' do
    login(users(:site_one_editor))
    assert_difference('Subject.count') do
      post :create, project_id: @project, subject: { subject_code: 'Code04' }, site_id: sites(:one).id
    end

    assert_redirected_to project_subject_path(assigns(:subject).project, assigns(:subject))
  end

  test 'should not create subject for site editor for another site' do
    login(users(:site_one_editor))
    assert_difference('Subject.count', 0) do
      post :create, project_id: @project, subject: { subject_code: 'Code04' }, site_id: sites(:two).id
    end

    assert_not_nil assigns(:project)
    assert_not_nil assigns(:subject)

    assert_not_nil assigns(:subject)
    assert assigns(:subject).errors.size > 0
    assert_equal ["can't be blank"], assigns(:subject).errors[:site_id]
    assert_template 'new'
  end

  test 'should show subject' do
    get :show, project_id: @project, id: @subject
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:subject)
    assert_response :success
  end

  test 'should show subject to site user' do
    login(users(:site_one_viewer))
    get :show, project_id: @project, id: @subject
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:subject)
    assert_response :success
  end

  test 'should not show invalid subject' do
    get :show, id: -1, project_id: @project
    assert_not_nil assigns(:project)
    assert_nil assigns(:subject)
    assert_redirected_to project_subjects_path
  end

  test 'should not show subject with invalid project' do
    get :show, id: @subject, project_id: -1

    assert_nil assigns(:project)
    assert_nil assigns(:subject)

    assert_redirected_to root_path
  end

  test 'should not show subject on different site to site user' do
    login(users(:site_one_viewer))
    get :show, id: subjects(:three), project_id: @project
    assert_nil assigns(:subject)
    assert_redirected_to project_subjects_path
  end

  test 'should get edit' do
    get :edit, project_id: @project, id: @subject
    assert_response :success
  end

  test 'should get edit for site editor' do
    login(users(:site_one_editor))
    get :edit, project_id: @project, id: @subject
    assert_response :success
  end

  test 'should not get edit for site editor for another site' do
    login(users(:site_one_editor))
    get :edit, id: subjects(:three), project_id: @project
    assert_redirected_to project_subjects_path
  end

  test 'should not get edit for site viewer' do
    login(users(:site_one_viewer))
    get :edit, project_id: @project, id: @subject
    assert_redirected_to root_path
  end

  test 'should not get edit for invalid subject' do
    get :edit, id: -1, project_id: @project

    assert_not_nil assigns(:project)
    assert_nil assigns(:subject)

    assert_redirected_to project_subjects_path
  end

  test 'should not get edit with invalid project' do
    get :edit, id: @subject, project_id: -1

    assert_nil assigns(:project)
    assert_nil assigns(:subject)

    assert_redirected_to root_path
  end

  test 'should update subject' do
    patch :update, project_id: @project, id: @subject,
                 subject: { subject_code: @subject.subject_code },
                 site_id: @subject.site_id
    assert_redirected_to project_subject_path(assigns(:subject).project, assigns(:subject))
  end

  test 'should update subject with blank subject code' do
    patch :update, project_id: @project, id: @subject, subject: { subject_code: '' }, site_id: @subject.site_id
    assert_not_nil assigns(:subject)
    assert assigns(:subject).errors.size > 0
    assert_equal ["can't be blank"], assigns(:subject).errors[:subject_code]
    assert_template 'edit'
  end

  test 'should not update invalid subject' do
    patch :update, id: -1, project_id: @project,
                 subject: { subject_code: @subject.subject_code },
                 site_id: @subject.site_id
    assert_nil assigns(:subject)
    assert_redirected_to project_subjects_path
  end

  test 'should not update subject with invalid project' do
    patch :update, id: @subject, project_id: -1,
                 subject: { subject_code: @subject.subject_code },
                 site_id: @subject.site_id
    assert_nil assigns(:subject)
    assert_nil assigns(:project)
    assert_redirected_to root_path
  end

  test 'should not update subject for site editor for another site' do
    login(users(:site_one_editor))
    patch :update, id: subjects(:three), project_id: @project,
                 subject: { subject_code: 'New Subject Code' },
                 site_id: sites(:one)
    assert_not_nil assigns(:project)
    assert_nil assigns(:subject)
    assert_redirected_to project_subjects_path
  end

  test 'should destroy unrandomized subject' do
    login(users(:valid))
    assert_difference('Subject.current.count', -1) do
      delete :destroy, project_id: projects(:one), id: subjects(:unrandomized)
    end
    assert_redirected_to project_subjects_path(projects(:one))
  end

  test 'should not destroy subject with invalid project' do
    assert_difference('Subject.current.count', 0) do
      delete :destroy, id: @subject, project_id: -1
    end

    assert_nil assigns(:project)
    assert_nil assigns(:subject)

    assert_redirected_to root_path
  end

  test 'should not destroy randomized subject' do
    login(users(:valid))
    assert_difference('Subject.current.count', 0) do
      delete :destroy, project_id: projects(:two), id: subjects(:randomized)
    end
    assert_redirected_to settings_project_subject_path(projects(:two), subjects(:randomized))
  end
end
