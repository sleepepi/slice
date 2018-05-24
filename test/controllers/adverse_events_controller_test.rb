# frozen_string_literal: true

require "test_helper"

# Tests the creation, modification, and visibility of adverse events by project
# and site staff.
class AdverseEventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project_editor = users(:regular)
    @site_editor = users(:site_one_editor)
    @site_viewer = users(:site_one_viewer)
    @project = projects(:one)
    @adverse_event = adverse_events(:one)
  end

  def adverse_event_params
    {
      subject_code: @adverse_event.subject_code,
      event_date: @adverse_event.event_date,
      description: @adverse_event.description,
      closed: @adverse_event.closed
    }
  end

  test "should get export as project editor" do
    login(@project_editor)
    get export_project_adverse_events_url(@project)
    assert_redirected_to [assigns(:project), assigns(:export)]
  end

  test "should not get export as site editor" do
    login(@site_editor)
    get export_project_adverse_events_url(@project)
    assert_redirected_to root_path
  end

  test "should not get export as site viewer" do
    login(@site_viewer)
    get export_project_adverse_events_url(@project)
    assert_redirected_to root_path
  end

  test "should get index as project editor" do
    login(@project_editor)
    get project_adverse_events_url(@project)
    assert_response :success
    assert_not_nil assigns(:adverse_events)
  end

  test "should get index ordered by reported by" do
    login(@project_editor)
    get project_adverse_events_url(@project, order: "reported_by")
    assert_response :success
    assert_not_nil assigns(:adverse_events)
  end

  test "should get index ordered by reported by desc" do
    login(@project_editor)
    get project_adverse_events_url(@project, order: "reported_by desc")
    assert_response :success
    assert_not_nil assigns(:adverse_events)
  end

  test "should get index ordered by site name" do
    login(@project_editor)
    get project_adverse_events_url(@project, order: "site")
    assert_response :success
    assert_not_nil assigns(:adverse_events)
  end

  test "should get index ordered by site name desc" do
    login(@project_editor)
    get project_adverse_events_url(@project, order: "site desc")
    assert_response :success
    assert_not_nil assigns(:adverse_events)
  end

  test "should get index ordered by subject code" do
    login(@project_editor)
    get project_adverse_events_url(@project, order: "subject")
    assert_response :success
    assert_not_nil assigns(:adverse_events)
  end

  test "should get index ordered by subject code desc" do
    login(@project_editor)
    get project_adverse_events_url(@project, order: "subject desc")
    assert_response :success
    assert_not_nil assigns(:adverse_events)
  end

  test "should get index ordered by created" do
    login(@project_editor)
    get project_adverse_events_url(@project, order: "created")
    assert_response :success
    assert_not_nil assigns(:adverse_events)
  end

  test "should get index ordered by created desc" do
    login(@project_editor)
    get project_adverse_events_url(@project, order: "created desc")
    assert_response :success
    assert_not_nil assigns(:adverse_events)
  end

  test "should get new as project editor" do
    login(@project_editor)
    get new_project_adverse_event_url(@project)
    assert_response :success
  end

  test "should get new as site editor" do
    login(@site_editor)
    get new_project_adverse_event_url(@project)
    assert_response :success
  end

  test "should not get new as site viewer" do
    login(@site_viewer)
    get new_project_adverse_event_url(@project)
    assert_redirected_to root_path
  end

  test "should create adverse event as project editor" do
    login(@project_editor)
    assert_difference("AdverseEvent.count") do
      post project_adverse_events_url(@project), params: {
        adverse_event: adverse_event_params
      }
    end
    assert_not_nil assigns(:adverse_event)
    assert_not_nil assigns(:adverse_event).number
    assert_redirected_to [assigns(:project), assigns(:adverse_event)]
  end

  test "should create adverse event as site editor" do
    login(@site_editor)
    assert_difference("AdverseEvent.count") do
      post project_adverse_events_url(@project), params: {
        adverse_event: adverse_event_params
      }
    end
    assert_not_nil assigns(:adverse_event)
    assert_not_nil assigns(:adverse_event).number
    assert_redirected_to [assigns(:project), assigns(:adverse_event)]
  end

  test "should not create adverse event with event date in the future" do
    login(@project_editor)
    assert_difference("AdverseEvent.count", 0) do
      post project_adverse_events_url(@project), params: {
        adverse_event: adverse_event_params.merge(
          event_date: (Time.zone.today + 1.day).strftime("%m/%d/%Y")
        )
      }
    end
    assert_not_nil assigns(:adverse_event)
    assert_equal ["can't be in the future"], assigns(:adverse_event).errors[:adverse_event_date]
    assert_template "new"
    assert_response :success
  end

  test "should not create adverse event as site viewer" do
    login(@site_viewer)
    assert_difference("AdverseEvent.count", 0) do
      post project_adverse_events_url(@project), params: {
        adverse_event: adverse_event_params
      }
    end
    assert_redirected_to root_path
  end

  test "should show adverse event as project editor" do
    login(@project_editor)
    get project_adverse_event_url(@project, @adverse_event)
    assert_response :success
  end

  test "should show adverse event as site editor" do
    login(@site_editor)
    get project_adverse_event_url(@project, @adverse_event)
    assert_response :success
  end

  test "should show adverse event as site viewer" do
    login(@site_viewer)
    get project_adverse_event_url(@project, @adverse_event)
    assert_response :success
  end

  test "should get adverse event forms as project editor" do
    login(@project_editor)
    get forms_project_adverse_event_url(@project, @adverse_event)
    assert_response :success
  end

  test "should get adverse event forms as site editor" do
    login(@site_editor)
    get forms_project_adverse_event_url(@project, @adverse_event)
    assert_response :success
  end

  test "should get adverse event forms as site viewer" do
    login(@site_viewer)
    get forms_project_adverse_event_url(@project, @adverse_event)
    assert_response :success
  end

  test "should get edit as project editor" do
    login(@project_editor)
    get edit_project_adverse_event_url(@project, @adverse_event)
    assert_response :success
  end

  test "should get edit as site editor" do
    login(@site_editor)
    get edit_project_adverse_event_url(@project, @adverse_event)
    assert_response :success
  end

  test "should not get edit as site viewer" do
    login(@site_viewer)
    get edit_project_adverse_event_url(@project, @adverse_event)
    assert_redirected_to root_path
  end

  test "should update adverse event as project editor" do
    login(@project_editor)
    patch project_adverse_event_url(@project, @adverse_event), params: {
      adverse_event: adverse_event_params
    }
    assert_redirected_to [assigns(:project), assigns(:adverse_event)]
  end

  test "should update adverse event as site editor" do
    login(@site_editor)
    patch project_adverse_event_url(@project, @adverse_event), params: {
      adverse_event: adverse_event_params
    }
    assert_redirected_to [assigns(:project), assigns(:adverse_event)]
  end

  test "should not update adverse event as site viewer" do
    login(@site_viewer)
    patch project_adverse_event_url(@project, @adverse_event), params: {
      adverse_event: adverse_event_params
    }
    assert_redirected_to root_path
  end

  test "should not update adverse event with blank description" do
    login(@project_editor)
    patch project_adverse_event_url(@project, @adverse_event), params: {
      adverse_event: adverse_event_params.merge(description: "")
    }
    assert_not_nil assigns(:adverse_event)
    assert_equal ["can't be blank"], assigns(:adverse_event).errors[:description]
    assert_template "edit"
  end

  test "should set shareable link as project editor" do
    login(@project_editor)
    post set_shareable_link_project_adverse_event_url(@project, @adverse_event)
    assert_not_nil assigns(:adverse_event).authentication_token
    assert_redirected_to [assigns(:project), assigns(:adverse_event)]
  end

  test "should remove shareable link as project editor" do
    login(@project_editor)
    post remove_shareable_link_project_adverse_event_url(@project, adverse_events(:shared))
    assert_nil assigns(:adverse_event).authentication_token
    assert_redirected_to [assigns(:project), assigns(:adverse_event)]
  end

  test "should destroy adverse event as project editor" do
    login(@project_editor)
    assert_difference("Notification.count", -1) do
      assert_difference("AdverseEvent.current.count", -1) do
        delete project_adverse_event_url(@project, @adverse_event)
      end
    end
    assert_redirected_to project_adverse_events_path(assigns(:project))
  end

  test "should destroy adverse event as site editor" do
    login(@site_editor)
    assert_difference("AdverseEvent.current.count", -1) do
      delete project_adverse_event_url(@project, @adverse_event)
    end
    assert_redirected_to project_adverse_events_path(assigns(:project))
  end

  test "should not destroy adverse event as site viewer" do
    login(@site_viewer)
    assert_difference("AdverseEvent.current.count", 0) do
      delete project_adverse_event_url(@project, @adverse_event)
    end
    assert_redirected_to root_path
  end
end
