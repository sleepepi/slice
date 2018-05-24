# frozen_string_literal: true

require 'test_helper'

# Tests to make sure project and site members can export data.
class ExportsControllerTest < ActionController::TestCase
  setup do
    @regular_user = users(:regular)
    @no_export_user = users(:project_one_editor)
    @project = projects(:one)
    @export = exports(:one)
  end

  test 'should get index' do
    login(@regular_user)
    get :index, params: { project_id: @project }
    assert_not_nil assigns(:exports)
    assert_response :success
  end

  test 'should get index and redirect' do
    login(@no_export_user)
    get :index, params: { project_id: @project }
    assert_redirected_to new_project_export_path(@project)
  end

  test 'should get new' do
    login(@regular_user)
    get :new, params: { project_id: @project }
    assert_response :success
  end

  test 'should create export with raw csv' do
    login(@regular_user)
    assert_difference('Export.count') do
      post :create, params: {
        project_id: @project, export: { include_csv_raw: '1' }
      }
    end
    assert_redirected_to [assigns(:project), assigns(:export)]
  end

  test 'should create export with labeled csv' do
    login(@regular_user)
    assert_difference('Export.count') do
      post :create, params: {
        project_id: @project, export: { include_csv_labeled: '1' }
      }
    end
    assert_redirected_to [assigns(:project), assigns(:export)]
  end

  test 'should create export with pdf collation' do
    login(@regular_user)
    assert_difference('Export.count') do
      post :create, params: {
        project_id: @project, export: { include_pdf: '1' }
      }
    end
    assert_redirected_to [assigns(:project), assigns(:export)]
  end

  test 'should create export with data dictionary' do
    login(@regular_user)
    assert_difference('Export.count') do
      post :create, params: {
        project_id: @project, export: { include_data_dictionary: '1' }
      }
    end
    assert_redirected_to [assigns(:project), assigns(:export)]
  end

  test 'should download export file' do
    login(@regular_user)
    assert_not_equal 0, @export.file.size
    get :file, params: { project_id: @project, id: @export }
    assert_not_nil response
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:export)
    assert_kind_of String, response.body
    assert_equal(
      File.binread(File.join(CarrierWave::Uploader::Base.root, assigns(:export).file.url)),
      response.body
    )
  end

  test 'should not download empty export file' do
    login(@regular_user)
    assert_equal 0, exports(:two).file.size
    get :file, params: { project_id: @project, id: exports(:two) }
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:export)
    assert_response :success
  end

  test 'should not download export file as non user' do
    login(@regular_user)
    assert_not_equal 0, @export.file.size
    login(users(:site_one_viewer))
    get :file, params: { project_id: @project, id: @export }
    assert_not_nil assigns(:project)
    assert_nil assigns(:export)
    assert_redirected_to project_exports_path(assigns(:project))
  end

  test 'should show export' do
    login(@regular_user)
    get :show, params: { project_id: @project, id: @export }
    assert_not_nil assigns(:export)
    assert_equal true, assigns(:export).viewed
    assert_response :success
  end

  test 'should not show invalid export' do
    login(@regular_user)
    get :show, params: { project_id: @project, id: -1 }
    assert_nil assigns(:export)
    assert_redirected_to project_exports_path(assigns(:project))
  end

  test 'should mark export as unread' do
    login(@regular_user)
    post :mark_unread, params: { project_id: @project, id: @export }
    assert_not_nil assigns(:export)
    assert_equal false, assigns(:export).viewed
    assert_redirected_to project_exports_path(assigns(:project))
  end

  test 'should mark invalid export as unread' do
    login(@regular_user)
    post :mark_unread, params: { project_id: @project, id: -1 }
    assert_nil assigns(:export)
    assert_redirected_to project_exports_path(assigns(:project))
  end

  test 'should destroy export' do
    login(@regular_user)
    assert_difference('Export.current.count', -1) do
      delete :destroy, params: { project_id: @project, id: @export }
    end
    assert_not_nil assigns(:export)
    assert_redirected_to project_exports_path(assigns(:project))
  end

  test 'should not destroy invalid export' do
    login(@regular_user)
    assert_difference('Export.current.count', 0) do
      delete :destroy, params: { project_id: @project, id: -1 }
    end
    assert_nil assigns(:export)
    assert_redirected_to project_exports_path(assigns(:project))
  end
end
