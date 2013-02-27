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

  test "should not get index with invalid project" do
    get :index, project_id: -1
    assert_nil assigns(:documents)
    assert_redirected_to root_path
  end

  test "should get new" do
    get :new, project_id: @project
    assert_response :success
  end

  test "should create document" do
    assert_difference('Document.count') do
      post :create, project_id: @project, document: { name: @document.name, archived: @document.archived, category: @document.category, file: fixture_file_upload('../../test/support/projects/rails.png') }
    end

    assert_redirected_to project_document_path(assigns(:document).project, assigns(:document))
  end

  test "should not create document with blank name" do
    assert_difference('Document.count', 0) do
      post :create, project_id: @project, document: { name: '', archived: @document.archived, category: @document.category, file: fixture_file_upload('../../test/support/projects/rails.png') }
    end

    assert_not_nil assigns(:document)
    assert assigns(:document).errors.size > 0
    assert_equal ["can't be blank"], assigns(:document).errors[:name]
    assert_template 'new'
  end

  test "should not create document with invalid project" do
    assert_difference('Document.count', 0) do
      post :create, project_id: -1, document: { name: @document.name, archived: @document.archived, category: @document.category, file: fixture_file_upload('../../test/support/projects/rails.png') }
    end

    assert_nil assigns(:document)
    assert_nil assigns(:project)
    assert_redirected_to root_path
  end

  test "should show document" do
    get :show, id: @document, project_id: @project
    assert_not_nil assigns(:document)
    assert_response :success
  end

  test "should not show document with invalid project" do
    get :show, id: @document, project_id: -1
    assert_nil assigns(:document)
    assert_redirected_to root_path
  end

  test "should get edit" do
    get :edit, id: @document, project_id: @project
    assert_not_nil assigns(:document)
    assert_response :success
  end

  test "should not get edit with invalid project" do
    get :edit, id: @document, project_id: -1
    assert_nil assigns(:document)
    assert_redirected_to root_path
  end

  test "should update document" do
    put :update, id: @document, project_id: @project, document: { name: @document.name, archived: @document.archived, category: @document.category, file: fixture_file_upload('../../test/support/projects/rails.png') }
    assert_redirected_to project_document_path(assigns(:document).project, assigns(:document))
  end

  test "should not update document with blank name" do
    put :update, id: @document, project_id: @project, document: { name: '', archived: @document.archived, category: @document.category, file: fixture_file_upload('../../test/support/projects/rails.png') }

    assert_not_nil assigns(:document)
    assert assigns(:document).errors.size > 0
    assert_equal ["can't be blank"], assigns(:document).errors[:name]
    assert_template 'edit'
  end

  test "should not update document with invalid project" do
    put :update, id: @document, project_id: -1, document: { name: @document.name, archived: @document.archived, category: @document.category, file: fixture_file_upload('../../test/support/projects/rails.png') }

    assert_nil assigns(:document)
    assert_nil assigns(:project)
    assert_redirected_to root_path
  end

  test "should destroy document" do
    assert_difference('Document.current.count', -1) do
      delete :destroy, id: @document, project_id: @project
    end

    assert_not_nil assigns(:document)
    assert_not_nil assigns(:project)

    assert_redirected_to project_documents_path
  end

  test "should not destroy document with invalid project" do
    assert_difference('Document.current.count', 0) do
      delete :destroy, id: @document, project_id: -1
    end

    assert_nil assigns(:document)
    assert_nil assigns(:project)

    assert_redirected_to root_path
  end
end
