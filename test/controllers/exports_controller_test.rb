require 'test_helper'

class ExportsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @project = projects(:one)
    @export = exports(:one)
  end

  test "should get index" do
    get :index, project_id: @project
    assert_response :success
    assert_not_nil assigns(:exports)
  end

  # test "should get new" do
  #   get :new
  #   assert_response :success
  # end

  # test "should create export" do
  #   assert_difference('Export.count') do
  #     post :create, export: { file: @export.file, include_files: @export.include_files, name: @export.name, project_id: @export.project_id, status: @export.status }
  #   end

  #   assert_redirected_to export_path(assigns(:export))
  # end

  test "should show export" do
    get :show, id: @export, project_id: @project
    assert_not_nil assigns(:export)
    assert_equal true, assigns(:export).viewed
    assert_response :success
  end

  test "should not show invalid export" do
    get :show, id: -1, project_id: @project
    assert_nil assigns(:export)
    assert_redirected_to project_exports_path(assigns(:project))
  end

  test "should mark export as unread" do
    post :mark_unread, id: @export, project_id: @project
    assert_not_nil assigns(:export)
    assert_equal false, assigns(:export).viewed
    assert_redirected_to project_exports_path(assigns(:project))
  end

  test "should mark invalid export as unread" do
    post :mark_unread, id: -1, project_id: @project
    assert_nil assigns(:export)
    assert_redirected_to project_exports_path(assigns(:project))
  end

  # test "should get edit" do
  #   get :edit, id: @export, project_id: @project
  #   assert_response :success
  # end

  # test "should update export" do
  #   put :update, id: @export, project_id: @project, export: { file: @export.file, include_files: @export.include_files, name: @export.name, status: @export.status }
  #   assert_redirected_to export_path(assigns(:export))
  # end

  test "should destroy export" do
    assert_difference('Export.current.count', -1) do
      delete :destroy, id: @export, project_id: @project
    end

    assert_not_nil assigns(:export)

    assert_redirected_to project_exports_path(assigns(:project))
  end

  test "should not destroy invalid export" do
    assert_difference('Export.current.count', 0) do
      delete :destroy, id: -1, project_id: @project
    end

    assert_nil assigns(:export)

    assert_redirected_to project_exports_path(assigns(:project))
  end
end
