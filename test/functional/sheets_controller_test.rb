require 'test_helper'

class SheetsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @sheet = sheets(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:sheets)
  end

  test "should get paginated index" do
    get :index, format: 'js'
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create sheet" do
    assert_difference('Sheet.count') do
      post :create, sheet: { description: @sheet.description, design_id: @sheet.design_id, name: 'Sheet Three', project_id: @sheet.project_id, study_date: '05/23/2012', subject_id: @sheet.subject_id }
    end

    assert_not_nil assigns(:sheet)

    assert_redirected_to sheet_path(assigns(:sheet))
  end

  test "should show sheet" do
    get :show, id: @sheet
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @sheet
    assert_response :success
  end

  test "should update sheet" do
    put :update, id: @sheet, sheet: { description: @sheet.description, design_id: @sheet.design_id, name: @sheet.name, project_id: @sheet.project_id, study_date: '05/23/2012', subject_id: @sheet.subject_id }
    assert_redirected_to sheet_path(assigns(:sheet))
  end

  test "should destroy sheet" do
    assert_difference('Sheet.current.count', -1) do
      delete :destroy, id: @sheet
    end

    assert_redirected_to sheets_path
  end
end
