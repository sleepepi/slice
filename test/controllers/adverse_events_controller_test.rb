require 'test_helper'

class AdverseEventsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @adverse_event = adverse_events(:one)
    @project = projects(:one)
  end

  test 'should get index' do
    get :index, project_id: @project
    assert_response :success
    assert_not_nil assigns(:adverse_events)
  end

  test 'should get new' do
    get :new, project_id: @project
    assert_response :success
  end

  test 'should create adverse event' do
    assert_difference('AdverseEvent.count') do
      post :create, project_id: @project, adverse_event: { subject_code: @adverse_event.subject_code, event_date: @adverse_event.event_date, description: @adverse_event.description, serious: @adverse_event.serious, closed: @adverse_event.closed }
    end

    assert_redirected_to [assigns(:project), assigns(:adverse_event)]
  end

  test 'should show adverse event' do
    get :show, project_id: @project, id: @adverse_event
    assert_response :success
  end

  test 'should get adverse event files' do
    get :files, project_id: @project, id: @adverse_event
    assert_response :success
  end

  test 'should get adverse event forms' do
    get :forms, project_id: @project, id: @adverse_event
    assert_response :success
  end

  test 'should get edit' do
    get :edit, project_id: @project, id: @adverse_event
    assert_response :success
  end

  test 'should update adverse event' do
    patch :update, project_id: @project, id: @adverse_event, adverse_event: { subject_id: @adverse_event.subject_code, event_date: @adverse_event.event_date, description: @adverse_event.description, serious: @adverse_event.serious, closed: @adverse_event.closed }
    assert_redirected_to [assigns(:project), assigns(:adverse_event)]
  end

  test 'should destroy adverse event' do
    assert_difference('AdverseEvent.current.count', -1) do
      delete :destroy, project_id: @project, id: @adverse_event
    end

    assert_redirected_to project_adverse_events_path(assigns(:project))
  end
end
