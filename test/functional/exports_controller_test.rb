require 'test_helper'

class ExportsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @export = exports(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:exports)
  end

  # test "should get new" do
  #   get :new
  #   assert_response :success
  # end

  # test "should create export" do
  #   assert_difference('Export.count') do
  #     post :create, export: { deleted: @export.deleted, export_type: @export.export_type, file: @export.file, include_files: @export.include_files, name: @export.name, project_id: @export.project_id, status: @export.status, user_id: @export.user_id }
  #   end

  #   assert_redirected_to export_path(assigns(:export))
  # end

  test "should show export" do
    get :show, id: @export
    assert_not_nil assigns(:export)
    assert_equal true, assigns(:export).viewed
    assert_response :success
  end

  test "should mark export as unread" do
    post :mark_unread, id: @export
    assert_not_nil assigns(:export)
    assert_equal false, assigns(:export).viewed
    assert_redirected_to exports_path
  end

  # test "should get edit" do
  #   get :edit, id: @export
  #   assert_response :success
  # end

  # test "should update export" do
  #   put :update, id: @export, export: { deleted: @export.deleted, export_type: @export.export_type, file: @export.file, include_files: @export.include_files, name: @export.name, project_id: @export.project_id, status: @export.status, user_id: @export.user_id }
  #   assert_redirected_to export_path(assigns(:export))
  # end

  test "should destroy export" do
    assert_difference('Export.current.count', -1) do
      delete :destroy, id: @export
    end

    assert_redirected_to exports_path
  end
end
