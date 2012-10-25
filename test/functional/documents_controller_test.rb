require 'test_helper'

class DocumentsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @project = projects(:one)
    @document = documents(:one)
  end

  test "should get index" do
    get :index, project_id: @project
    assert_response :success
    assert_not_nil assigns(:documents)
  end

  test "should get new" do
    get :new, project_id: @project
    assert_response :success
  end

  test "should create document" do
    assert_difference('Document.count') do
      post :create, project_id: @project, document: { archived: @document.archived, category: @document.category, file: fixture_file_upload('../../test/support/projects/rails.png'), name: @document.name }
    end

    assert_redirected_to project_document_path(assigns(:document).project, assigns(:document))
  end

  test "should show document" do
    get :show, id: @document, project_id: @project
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @document, project_id: @project
    assert_response :success
  end

  test "should update document" do
    put :update, id: @document, project_id: @project, document: { archived: @document.archived, category: @document.category, file: fixture_file_upload('../../test/support/projects/rails.png'), name: @document.name }
    assert_redirected_to project_document_path(assigns(:document).project, assigns(:document))
  end

  test "should destroy document" do
    assert_difference('Document.current.count', -1) do
      delete :destroy, id: @document, project_id: @project
    end

    assert_redirected_to project_documents_path
  end
end
