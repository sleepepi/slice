require 'test_helper'

class EventsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @project = projects(:one)
    @event = events(:one)
  end

  test "should get index" do
    get :index, project_id: @project
    assert_response :success
    assert_not_nil assigns(:events)
  end

  test "should not get index with invalid project" do
    get :index, project_id: -1
    assert_nil assigns(:events)
    assert_redirected_to root_path
  end

  test "should get new" do
    get :new, project_id: @project
    assert_response :success
  end

  test "should create event" do
    assert_difference('Event.count') do
      post :create, project_id: @project, event: { name: 'New Event', description: @event.description }
    end

    assert_redirected_to project_event_path(assigns(:event).project, assigns(:event))
  end

  test "should not create event with blank name" do
    assert_difference('Event.count', 0) do
      post :create, project_id: @project, event: { name: '', description: @event.description }
    end

    assert_not_nil assigns(:event)
    assert assigns(:event).errors.size > 0
    assert_equal ["can't be blank"], assigns(:event).errors[:name]
    assert_template 'new'
  end

  test "should not create event with invalid project" do
    assert_difference('Event.count', 0) do
      post :create, project_id: -1, event: { name: 'New Event', description: @event.description }
    end

    assert_nil assigns(:event)
    assert_nil assigns(:project)
    assert_redirected_to root_path
  end

  test "should show event" do
    get :show, id: @event, project_id: @project
    assert_not_nil assigns(:event)
    assert_response :success
  end

  test "should not show event with invalid project" do
    get :show, id: @event, project_id: -1
    assert_nil assigns(:event)
    assert_redirected_to root_path
  end

  test "should get edit" do
    get :edit, id: @event, project_id: @project
    assert_not_nil assigns(:event)
    assert_response :success
  end

  test "should not get edit with invalid project" do
    get :edit, id: @event, project_id: -1
    assert_nil assigns(:event)
    assert_redirected_to root_path
  end

  test "should update event" do
    put :update, id: @event, project_id: @project, event: { name: 'Event One Updated', description: @event.description }
    assert_redirected_to project_event_path(assigns(:event).project, assigns(:event))
  end

  test "should not update event with blank name" do
    put :update, id: @event, project_id: @project, event: { name: '', description: @event.description }

    assert_not_nil assigns(:event)
    assert assigns(:event).errors.size > 0
    assert_equal ["can't be blank"], assigns(:event).errors[:name]
    assert_template 'edit'
  end

  test "should not update event with invalid project" do
    put :update, id: @event, project_id: -1, event: { name: 'Event One Updated', description: @event.description }

    assert_nil assigns(:event)
    assert_nil assigns(:project)
    assert_redirected_to root_path
  end

  test "should destroy event" do
    assert_difference('Event.current.count', -1) do
      delete :destroy, id: @event, project_id: @project
    end

    assert_not_nil assigns(:event)
    assert_not_nil assigns(:project)

    assert_redirected_to project_events_path
  end

  test "should not destroy event with invalid project" do
    assert_difference('Event.current.count', 0) do
      delete :destroy, id: @event, project_id: -1
    end

    assert_nil assigns(:event)
    assert_nil assigns(:project)

    assert_redirected_to root_path
  end
end
