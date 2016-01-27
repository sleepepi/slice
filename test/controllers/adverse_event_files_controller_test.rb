# frozen_string_literal: true

require 'test_helper'

class AdverseEventFilesControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @project = projects(:one)
    @adverse_event = adverse_events(:one)
    @adverse_event_file = adverse_event_files(:one)
  end

  test 'should get index as project editor' do
    get :index, project_id: @project, adverse_event_id: @adverse_event
    assert_not_nil assigns(:adverse_event)
    assert_not_nil assigns(:adverse_event_files)
    assert_response :success
  end

  test 'should get index as site editor' do
    login(users(:site_one_editor))
    get :index, project_id: @project, adverse_event_id: @adverse_event
    assert_not_nil assigns(:adverse_event)
    assert_not_nil assigns(:adverse_event_files)
    assert_response :success
  end

  test 'should get index as site viewer' do
    login(users(:site_one_viewer))
    get :index, project_id: @project, adverse_event_id: @adverse_event
    assert_not_nil assigns(:adverse_event)
    assert_not_nil assigns(:adverse_event_files)
    assert_response :success
  end

  test 'should get new as project editor' do
    get :new, project_id: @project, adverse_event_id: @adverse_event
    assert_response :success
  end

  test 'should get new as site editor' do
    login(users(:site_one_editor))
    get :new, project_id: @project, adverse_event_id: @adverse_event
    assert_response :success
  end

  test 'should not get new as site viewer' do
    login(users(:site_one_viewer))
    get :new, project_id: @project, adverse_event_id: @adverse_event
    assert_redirected_to root_path
  end

  test 'should create adverse event file as project editor' do
    assert_difference('AdverseEventFile.count') do
      post :create, project_id: @project, adverse_event_id: @adverse_event, adverse_event_file: { attachment: fixture_file_upload('../../test/support/projects/rails.png') }
    end

    assert_redirected_to project_adverse_event_adverse_event_files_path(assigns(:project), assigns(:adverse_event))
  end

  test 'should create adverse event file as site editor' do
    login(users(:site_one_editor))
    assert_difference('AdverseEventFile.count') do
      post :create, project_id: @project, adverse_event_id: @adverse_event, adverse_event_file: { attachment: fixture_file_upload('../../test/support/projects/rails.png') }
    end

    assert_redirected_to project_adverse_event_adverse_event_files_path(assigns(:project), assigns(:adverse_event))
  end

  test 'should not create adverse event file as site viewer' do
    login(users(:site_one_viewer))
    assert_difference('AdverseEventFile.count', 0) do
      post :create, project_id: @project, adverse_event_id: @adverse_event, adverse_event_file: { attachment: fixture_file_upload('../../test/support/projects/rails.png') }
    end

    assert_redirected_to root_path
  end

  test 'should get show as project editor' do
    get :show, project_id: @project, adverse_event_id: @adverse_event, id: @adverse_event_file
    assert_response :success
  end

  test 'should get show as site editor' do
    login(users(:site_one_editor))
    get :show, project_id: @project, adverse_event_id: @adverse_event, id: @adverse_event_file
    assert_response :success
  end

  test 'should get show as site viewer' do
    login(users(:site_one_viewer))
    get :show, project_id: @project, adverse_event_id: @adverse_event, id: @adverse_event_file
    assert_response :success
  end

  test 'should destroy adverse event file as project editor' do
    assert_difference('AdverseEventFile.count', -1) do
      delete :destroy, project_id: @project, adverse_event_id: @adverse_event, id: @adverse_event_file
    end

    assert_redirected_to project_adverse_event_adverse_event_files_path(assigns(:project), assigns(:adverse_event))
  end

  test 'should destroy adverse event file as site editor' do
    login(users(:site_one_editor))
    assert_difference('AdverseEventFile.count', -1) do
      delete :destroy, project_id: @project, adverse_event_id: @adverse_event, id: @adverse_event_file
    end

    assert_redirected_to project_adverse_event_adverse_event_files_path(assigns(:project), assigns(:adverse_event))
  end

  test 'should not destroy adverse event file as site viewer' do
    login(users(:site_one_viewer))
    assert_difference('AdverseEventFile.count', 0) do
      delete :destroy, project_id: @project, adverse_event_id: @adverse_event, id: @adverse_event_file
    end

    assert_redirected_to root_path
  end
end
