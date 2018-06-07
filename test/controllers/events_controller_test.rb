# frozen_string_literal: true

require "test_helper"

# Tests to assure that project editors can view and modify events.
class EventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project_editor = users(:regular)
    @project = projects(:one)
    @event = events(:one)
  end

  test "should add design" do
    login(@project_editor)
    post add_design_project_events_url(@project, format: "js")
    assert_template "add_design"
    assert_response :success
  end

  test "should get index" do
    login(@project_editor)
    get project_events_url(@project)
    assert_response :success
  end

  test "should not get index with invalid project" do
    login(@project_editor)
    get project_events_url(-1)
    assert_redirected_to root_url
  end

  test "should get new" do
    login(@project_editor)
    get new_project_event_url(@project)
    assert_response :success
  end

  test "should create event" do
    login(@project_editor)
    assert_difference("Event.count") do
      post project_events_url(@project), params: {
        event: { name: "New Event", description: @event.description }
      }
    end
    assert_redirected_to project_event_url(assigns(:event).project, assigns(:event))
  end

  test "should create event with two designs" do
    login(@project_editor)
    assert_difference("Event.count") do
      post project_events_url(@project), params: {
        event: {
          name: "New Event",
          description: @event.description,
          design_hashes: [
            { design_id: designs(:one).id, handoff_enabled: "0" },
            { design_id: designs(:all_variable_types).id, handoff_enabled: "1" }
          ]
        }
      }
    end
    assert_equal 2, assigns(:event).designs.count
    assert_redirected_to project_event_url(assigns(:event).project, assigns(:event))
  end

  test "should not create event with blank name" do
    login(@project_editor)
    assert_difference("Event.count", 0) do
      post project_events_url(@project), params: {
        event: { name: "", description: @event.description }
      }
    end
    assert_not_nil assigns(:event)
    assert_equal ["can't be blank"], assigns(:event).errors[:name]
    assert_template "new"
  end

  test "should not create event with invalid project" do
    login(@project_editor)
    assert_difference("Event.count", 0) do
      post project_events_url(-1), params: {
        event: { name: "New Event", description: @event.description }
      }
    end
    assert_redirected_to root_url
  end

  test "should show event" do
    login(@project_editor)
    get project_event_url(@project, @event)
    assert_response :success
  end

  test "should not show event with invalid project" do
    login(@project_editor)
    get project_event_url(-1, @event)
    assert_redirected_to root_url
  end

  test "should get edit" do
    login(@project_editor)
    get edit_project_event_url(@project, @event)
    assert_response :success
  end

  test "should not get edit with invalid project" do
    login(@project_editor)
    get edit_project_event_url(-1, @event)
    assert_redirected_to root_url
  end

  test "should update event" do
    login(@project_editor)
    patch project_event_url(@project, @event), params: {
      event: { name: "Event One Updated", description: @event.description }
    }
    assert_redirected_to project_event_url(assigns(:event).project, assigns(:event))
  end

  test "should update event with ajax" do
    login(@project_editor)
    patch project_event_url(@project, @event, format: "js"), params: {
      event: { name: "Event One Updated", description: @event.description }
    }
    assert_template "update"
    assert_response :success
  end

  test "should not update event with blank name" do
    login(@project_editor)
    patch project_event_url(@project, @event), params: {
      event: { name: "", description: @event.description }
    }
    assert_not_nil assigns(:event)
    assert_equal ["can't be blank"], assigns(:event).errors[:name]
    assert_template "edit"
  end

  test "should not update event with invalid project" do
    login(@project_editor)
    patch project_event_url(-1, @event), params: {
      event: { name: "Event One Updated", description: @event.description }
    }
    assert_redirected_to root_url
  end

  test "should destroy event" do
    login(@project_editor)
    assert_difference("Event.current.count", -1) do
      delete project_event_url(@project, @event)
    end
    assert_redirected_to project_events_url(@project)
  end

  test "should destroy event with ajax" do
    login(@project_editor)
    assert_difference("Event.current.count", -1) do
      delete project_event_url(@project, @event, format: "js")
    end
    assert_template "destroy"
    assert_response :success
  end

  test "should not destroy event with invalid project" do
    login(@project_editor)
    assert_difference("Event.current.count", 0) do
      delete project_event_url(-1, @event)
    end
    assert_redirected_to root_url
  end
end
