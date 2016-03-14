# frozen_string_literal: true

require 'test_helper'

# Project editors should be able to launch handoffs for subjects with existing
# subject events.
class HandoffsControllerTest < ActionController::TestCase
  setup do
    @handoff = handoffs(:one)
    @project = projects(:one)
  end

  test 'should get new as project editor' do
    login(users(:valid))
    get :new, params: {
      project_id: @project, id: subjects(:three),
      subject_event_id: subject_events(:three)
    }
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:subject)
    assert_response :success
  end

  test 'should get new as project editor for existing handoff' do
    login(users(:valid))
    get :new, params: {
      project_id: @project, id: subjects(:two),
      subject_event_id: subject_events(:two)
    }
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:subject)
    assert_response :success
  end

  test 'should not get new as project viewer' do
    login(users(:associated))
    get :new, params: {
      project_id: @project, id: subjects(:three),
      subject_event_id: subject_events(:three)
    }
    assert_nil assigns(:project)
    assert_nil assigns(:subject)
    assert_redirected_to root_path
  end

  test 'should not get new as site editor from different site as subject' do
    login(users(:site_one_editor))
    get :new, params: {
      project_id: @project, id: subjects(:three),
      subject_event_id: subject_events(:three)
    }
    assert_not_nil assigns(:project)
    assert_nil assigns(:subject)
    assert_redirected_to project_subjects_path(assigns(:project))
  end

  test 'should launch new handoff as project editor' do
    login(users(:valid))
    assert_difference('Handoff.count') do
      post :create, params: {
        project_id: @project, id: subjects(:three),
        subject_event_id: subject_events(:three)
      }
    end
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:subject)
    assert_not_nil assigns(:handoff)
    assert_not_nil assigns(:handoff).token
    assert_equal users(:valid), assigns(:handoff).user
    assert_redirected_to handoff_start_path(assigns(:project), assigns(:handoff))
  end

  test 'should launch existing handoff as project editor' do
    login(users(:valid))
    assert_difference('Handoff.count', 0) do
      post :create, params: {
        project_id: @project, id: subjects(:two),
        subject_event_id: subject_events(:two)
      }
    end
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:subject)
    assert_not_nil assigns(:handoff)
    assert_not_nil assigns(:handoff).token
    assert_equal users(:admin), assigns(:handoff).user
    assert_redirected_to handoff_start_path(assigns(:project), assigns(:handoff))
  end

  test 'should not launch new handoff as project viewer' do
    login(users(:associated))
    assert_difference('Handoff.count', 0) do
      post :create, params: {
        project_id: @project, id: subjects(:three),
        subject_event_id: subject_events(:three)
      }
    end
    assert_nil assigns(:project)
    assert_nil assigns(:subject)
    assert_nil assigns(:handoff)
    assert_redirected_to root_path
  end

  test 'should not launch new handoff as site editor from different site as subject' do
    login(users(:site_one_editor))
    assert_difference('Handoff.count', 0) do
      post :create, params: {
        project_id: @project, id: subjects(:three),
        subject_event_id: subject_events(:three)
      }
    end
    assert_not_nil assigns(:project)
    assert_nil assigns(:subject)
    assert_nil assigns(:handoff)
    assert_redirected_to project_subjects_path(assigns(:project))
  end
end
