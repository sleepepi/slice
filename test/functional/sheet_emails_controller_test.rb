require 'test_helper'

class SheetEmailsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @sheet_email = sheet_emails(:one)
  end

  test "should show sheet email" do
    get :show, id: @sheet_email, project_id: projects(:one)
    assert_not_nil assigns(:sheet_email)
    assert_not_nil assigns(:project)
    assert_response :success
  end

  test "should not show invalid sheet email" do
    get :show, id: -1, project_id: projects(:one)
    assert_not_nil assigns(:project)
    assert_nil assigns(:sheet_email)
    assert_redirected_to project_sheets_path(assigns(:project))
  end

  test "should not show invalid sheet email and invalid project" do
    get :show, id: -1, project_id: -1
    assert_nil assigns(:sheet_email)
    assert_nil assigns(:project)
    assert_redirected_to root_path
  end
end
