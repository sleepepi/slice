# frozen_string_literal: true

require "test_helper"

# Project editors should be able to launch handoffs for subjects with existing
# subject events.
class HandoffsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @handoff = handoffs(:one)
    @project = projects(:one)
    @project_editor = users(:project_one_editor)
    @project_viewer = users(:project_one_viewer)
    @site_editor = users(:site_one_editor)
  end

  test "should get new as project editor" do
    login(@project_editor)
    get new_handoff_project_subject_url(@project, subjects(:three), subject_events(:three))
    assert_response :success
  end

  test "should get new as project editor for existing handoff" do
    login(@project_editor)
    get new_handoff_project_subject_url(@project, subjects(:two), subject_events(:two))
    assert_response :success
  end

  test "should not get new as project viewer" do
    login(@project_viewer)
    get new_handoff_project_subject_url(@project, subjects(:three), subject_events(:three))
    assert_redirected_to root_url
  end

  test "should not get new as site editor from different site as subject" do
    login(@site_editor)
    get new_handoff_project_subject_url(@project, subjects(:three), subject_events(:three))
    assert_redirected_to project_subjects_url(@project)
  end

  test "should launch new handoff as project editor" do
    login(@project_editor)
    assert_difference("Handoff.count") do
      post create_handoff_project_subject_url(@project, subjects(:three), subject_events(:three))
    end
    assert_not_nil assigns(:handoff)
    assert_not_nil assigns(:handoff).token
    assert_equal @project_editor, assigns(:handoff).user
    assert_redirected_to handoff_start_url(@project, assigns(:handoff))
  end

  test "should launch existing handoff as project editor" do
    login(@project_editor)
    assert_difference("Handoff.count", 0) do
      post create_handoff_project_subject_url(@project, subjects(:two), subject_events(:two))
    end
    assert_not_nil assigns(:handoff)
    assert_not_nil assigns(:handoff).token
    assert_equal users(:admin), assigns(:handoff).user
    assert_redirected_to handoff_start_url(@project, assigns(:handoff))
  end

  test "should not launch new handoff as project viewer" do
    login(@project_viewer)
    assert_difference("Handoff.count", 0) do
      post create_handoff_project_subject_url(@project, subjects(:three), subject_events(:three))
    end
    assert_redirected_to root_url
  end

  test "should not launch new handoff as site editor from different site as subject" do
    login(@site_editor)
    assert_difference("Handoff.count", 0) do
      post create_handoff_project_subject_url(@project, subjects(:three), subject_events(:three))
    end
    assert_redirected_to project_subjects_url(@project)
  end
end
