require 'test_helper'

class AdverseEventsControllerTest < ActionController::TestCase
  setup do
    @project = projects(:one)
    @adverse_event = adverse_events(:one)
  end

  test 'should get export as project editor' do
    login(users(:valid))
    get :export, project_id: @project
    assert_response :success
  end

  test 'should not get export as site editor' do
    login(users(:site_one_editor))
    get :export, project_id: @project
    assert_redirected_to root_path
  end

  test 'should not get export as site viewer' do
    login(users(:site_one_viewer))
    get :export, project_id: @project
    assert_redirected_to root_path
  end

  test 'should get index as project editor' do
    login(users(:valid))
    get :index, project_id: @project
    assert_response :success
    assert_not_nil assigns(:adverse_events)
  end

  test 'should get new as project editor' do
    login(users(:valid))
    get :new, project_id: @project
    assert_response :success
  end

  test 'should get new as site editor' do
    login(users(:site_one_editor))
    get :new, project_id: @project
    assert_response :success
  end

  test 'should not get new as site viewer' do
    login(users(:site_one_viewer))
    get :new, project_id: @project
    assert_redirected_to root_path
  end

  test 'should create adverse event as project editor' do
    login(users(:valid))
    assert_difference('AdverseEvent.count') do
      post :create, project_id: @project, adverse_event: { subject_code: @adverse_event.subject_code, event_date: @adverse_event.event_date, description: @adverse_event.description, serious: @adverse_event.serious, closed: @adverse_event.closed }
    end

    assert_redirected_to [assigns(:project), assigns(:adverse_event)]
  end

  test 'should create adverse event as site editor' do
    login(users(:site_one_editor))
    assert_difference('AdverseEvent.count') do
      post :create, project_id: @project, adverse_event: { subject_code: @adverse_event.subject_code, event_date: @adverse_event.event_date, description: @adverse_event.description, serious: @adverse_event.serious, closed: @adverse_event.closed }
    end

    assert_redirected_to [assigns(:project), assigns(:adverse_event)]
  end

  test 'should not create adverse event as site viewer' do
    login(users(:site_one_viewer))
    assert_difference('AdverseEvent.count', 0) do
      post :create, project_id: @project, adverse_event: { subject_code: @adverse_event.subject_code, event_date: @adverse_event.event_date, description: @adverse_event.description, serious: @adverse_event.serious, closed: @adverse_event.closed }
    end

    assert_redirected_to root_path
  end

  test 'should show adverse event as project editor' do
    login(users(:valid))
    get :show, project_id: @project, id: @adverse_event
    assert_response :success
  end

  test 'should show adverse event as site editor' do
    login(users(:site_one_editor))
    get :show, project_id: @project, id: @adverse_event
    assert_response :success
  end

  test 'should show adverse event as site viewer' do
    login(users(:site_one_viewer))
    get :show, project_id: @project, id: @adverse_event
    assert_response :success
  end

  test 'should get adverse event forms as project editor' do
    login(users(:valid))
    get :forms, project_id: @project, id: @adverse_event
    assert_response :success
  end

  test 'should get adverse event forms as site editor' do
    login(users(:site_one_editor))
    get :forms, project_id: @project, id: @adverse_event
    assert_response :success
  end

  test 'should get adverse event forms as site viewer' do
    login(users(:site_one_viewer))
    get :forms, project_id: @project, id: @adverse_event
    assert_response :success
  end

  test 'should get edit as project editor' do
    login(users(:valid))
    get :edit, project_id: @project, id: @adverse_event
    assert_response :success
  end

  test 'should get edit as site editor' do
    login(users(:site_one_editor))
    get :edit, project_id: @project, id: @adverse_event
    assert_response :success
  end

  test 'should not get edit as site viewer' do
    login(users(:site_one_viewer))
    get :edit, project_id: @project, id: @adverse_event
    assert_redirected_to root_path
  end

  test 'should update adverse event as project editor' do
    login(users(:valid))
    patch :update, project_id: @project, id: @adverse_event, adverse_event: { subject_id: @adverse_event.subject_code, event_date: @adverse_event.event_date, description: @adverse_event.description, serious: @adverse_event.serious, closed: @adverse_event.closed }
    assert_redirected_to [assigns(:project), assigns(:adverse_event)]
  end

  test 'should update adverse event as site editor' do
    login(users(:site_one_editor))
    patch :update, project_id: @project, id: @adverse_event, adverse_event: { subject_id: @adverse_event.subject_code, event_date: @adverse_event.event_date, description: @adverse_event.description, serious: @adverse_event.serious, closed: @adverse_event.closed }
    assert_redirected_to [assigns(:project), assigns(:adverse_event)]
  end

  test 'should not update adverse event as site viewer' do
    login(users(:site_one_viewer))
    patch :update, project_id: @project, id: @adverse_event, adverse_event: { subject_id: @adverse_event.subject_code, event_date: @adverse_event.event_date, description: @adverse_event.description, serious: @adverse_event.serious, closed: @adverse_event.closed }
    assert_redirected_to root_path
  end

  test 'should destroy adverse event as project editor' do
    login(users(:valid))
    assert_difference('AdverseEvent.current.count', -1) do
      delete :destroy, project_id: @project, id: @adverse_event
    end

    assert_redirected_to project_adverse_events_path(assigns(:project))
  end

  test 'should destroy adverse event as site editor' do
    login(users(:site_one_editor))
    assert_difference('AdverseEvent.current.count', -1) do
      delete :destroy, project_id: @project, id: @adverse_event
    end

    assert_redirected_to project_adverse_events_path(assigns(:project))
  end

  test 'should not destroy adverse event as site viewer' do
    login(users(:site_one_viewer))
    assert_difference('AdverseEvent.current.count', 0) do
      delete :destroy, project_id: @project, id: @adverse_event
    end

    assert_redirected_to root_path
  end
end
