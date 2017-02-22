# frozen_string_literal: true

require 'test_helper'

# Tests uploading files to adverse events
class AdverseEventFilesControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @project = projects(:one)
    @adverse_event = adverse_events(:one)
    @adverse_event_file = adverse_event_files(:one)
  end

  test 'should get index as project editor' do
    get :index, params: {
      project_id: @project, adverse_event_id: @adverse_event
    }
    assert_not_nil assigns(:adverse_event)
    assert_not_nil assigns(:adverse_event_files)
    assert_response :success
  end

  test 'should get index as site editor' do
    login(users(:site_one_editor))
    get :index, params: {
      project_id: @project, adverse_event_id: @adverse_event
    }
    assert_not_nil assigns(:adverse_event)
    assert_not_nil assigns(:adverse_event_files)
    assert_response :success
  end

  test 'should get index as site viewer' do
    login(users(:site_one_viewer))
    get :index, params: {
      project_id: @project, adverse_event_id: @adverse_event
    }
    assert_not_nil assigns(:adverse_event)
    assert_not_nil assigns(:adverse_event_files)
    assert_response :success
  end

  test 'should get new as project editor' do
    get :new, params: {
      project_id: @project, adverse_event_id: @adverse_event
    }
    assert_response :success
  end

  test 'should get new as site editor' do
    login(users(:site_one_editor))
    get :new, params: {
      project_id: @project, adverse_event_id: @adverse_event
    }
    assert_response :success
  end

  test 'should not get new as site viewer' do
    login(users(:site_one_viewer))
    get :new, params: {
      project_id: @project, adverse_event_id: @adverse_event
    }
    assert_redirected_to root_path
  end

  test 'should create adverse event file as project editor' do
    assert_difference('AdverseEventFile.count') do
      post :create, params: {
        project_id: @project, adverse_event_id: @adverse_event,
        adverse_event_file: { attachment: fixture_file_upload('../../test/support/projects/rails.png') }
      }
    end
    assert_redirected_to project_adverse_event_adverse_event_files_path(assigns(:project), assigns(:adverse_event))
  end

  test 'should create adverse event file as site editor' do
    login(users(:site_one_editor))
    assert_difference('AdverseEventFile.count') do
      post :create, params: {
        project_id: @project, adverse_event_id: @adverse_event,
        adverse_event_file: { attachment: fixture_file_upload('../../test/support/projects/rails.png') }
      }
    end
    assert_redirected_to project_adverse_event_adverse_event_files_path(assigns(:project), assigns(:adverse_event))
  end

  test 'should not create adverse event file without file' do
    assert_difference('AdverseEventFile.count', 0) do
      post :create, params: {
        project_id: @project, adverse_event_id: @adverse_event, adverse_event_file: { attachment: '' }
      }
    end
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:adverse_event)
    assert_not_nil assigns(:adverse_event_file)
    assert_equal ["can't be blank"], assigns(:adverse_event_file).errors[:attachment]
    assert_template 'new'
    assert_response :success
  end

  test 'should not create adverse event file as site viewer' do
    login(users(:site_one_viewer))
    assert_difference('AdverseEventFile.count', 0) do
      post :create, params: {
        project_id: @project, adverse_event_id: @adverse_event,
        adverse_event_file: { attachment: fixture_file_upload('../../test/support/projects/rails.png') }
      }
    end

    assert_redirected_to root_path
  end

  test 'should create multiple file attachments as project editor' do
    assert_difference('AdverseEventFile.count', 2) do
      post :create_multiple, params: {
        project_id: @project, adverse_event_id: @adverse_event,
        attachments: [fixture_file_upload('../../test/support/projects/rails.png'),
                      fixture_file_upload('../../test/support/projects/rails.png')]
      }, format: 'js'
    end
    assert_template 'index'
    assert_response :success
  end

  test 'should get show as project editor' do
    get :show, params: { project_id: @project, adverse_event_id: @adverse_event, id: @adverse_event_file }
    assert_response :success
  end

  test 'should get show as site editor' do
    login(users(:site_one_editor))
    get :show, params: { project_id: @project, adverse_event_id: @adverse_event, id: @adverse_event_file }
    assert_response :success
  end

  test 'should get show as site viewer' do
    login(users(:site_one_viewer))
    get :show, params: { project_id: @project, adverse_event_id: @adverse_event, id: @adverse_event_file }
    assert_response :success
  end

  test 'should download image as project editor' do
    get :download, params: {
      project_id: @project, adverse_event_id: @adverse_event, id: @adverse_event_file
    }
    assert_not_nil response
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:adverse_event)
    assert_not_nil assigns(:adverse_event_file)
    assert_kind_of String, response.body
    assert_equal File.binread(File.join(CarrierWave::Uploader::Base.root, assigns(:adverse_event_file).attachment.url)),
                 response.body
    assert_response :success
  end

  test 'should download pdf as project editor' do
    get :download, params: {
      project_id: @project, adverse_event_id: @adverse_event, id: adverse_event_files(:two)
    }
    assert_not_nil response
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:adverse_event)
    assert_not_nil assigns(:adverse_event_file)
    assert_kind_of String, response.body
    assert_equal File.binread(File.join(CarrierWave::Uploader::Base.root, assigns(:adverse_event_file).attachment.url)),
                 response.body
    assert_response :success
  end

  test 'should destroy adverse event file as project editor' do
    assert_difference('AdverseEventFile.count', -1) do
      delete :destroy, params: { project_id: @project, adverse_event_id: @adverse_event, id: adverse_event_files(:delete_me)
      }
    end
    assert_redirected_to project_adverse_event_adverse_event_files_path(assigns(:project), assigns(:adverse_event))
  end

  test 'should destroy adverse event file as site editor' do
    login(users(:site_one_editor))
    assert_difference('AdverseEventFile.count', -1) do
      delete :destroy, params: { project_id: @project, adverse_event_id: @adverse_event, id: adverse_event_files(:delete_me)
      }
    end
    assert_redirected_to project_adverse_event_adverse_event_files_path(assigns(:project), assigns(:adverse_event))
  end

  test 'should not destroy adverse event file as site viewer' do
    login(users(:site_one_viewer))
    assert_difference('AdverseEventFile.count', 0) do
      delete :destroy, params: { project_id: @project, adverse_event_id: @adverse_event, id: adverse_event_files(:delete_me)
      }
    end
    assert_redirected_to root_path
  end
end
