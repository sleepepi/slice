require 'test_helper'

class AdverseEventFilesControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @project = projects(:one)
    @adverse_event = adverse_events(:one)
    @adverse_event_file = adverse_event_files(:one)
  end

  test 'should get index' do
    get :index, project_id: @project, adverse_event_id: @adverse_event
    assert_not_nil assigns(:adverse_event)
    assert_not_nil assigns(:adverse_event_files)
    assert_response :success
  end

  test 'should get new' do
    get :new, project_id: @project, adverse_event_id: @adverse_event
    assert_response :success
  end

  test 'should create adverse_event_file' do
    assert_difference('AdverseEventFile.count') do
      post :create, project_id: @project, adverse_event_id: @adverse_event, adverse_event_file: { attachment: fixture_file_upload('../../test/support/projects/rails.png') }
    end

    assert_redirected_to project_adverse_event_adverse_event_files_path(assigns(:project), assigns(:adverse_event))
  end

  test 'should get show' do
    get :show, project_id: @project, adverse_event_id: @adverse_event, id: @adverse_event_file
    assert_response :success
  end

  test 'should destroy adverse_event_file' do
    assert_difference('AdverseEventFile.count', -1) do
      delete :destroy, project_id: @project, adverse_event_id: @adverse_event, id: @adverse_event_file
    end

    assert_redirected_to project_adverse_event_adverse_event_files_path(assigns(:project), assigns(:adverse_event))
  end
end
