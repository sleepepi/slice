require 'test_helper'

class ListsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @project = projects(:one)
    @randomization_scheme = randomization_schemes(:one)
    @list = lists(:one)
  end

  test "should get index" do
    get :index, project_id: @project, randomization_scheme_id: @randomization_scheme
    assert_response :success
    assert_not_nil assigns(:lists)
  end

  test "should get new" do
    get :new, project_id: @project, randomization_scheme_id: @randomization_scheme
    assert_response :success
  end

  test "should create list" do
    assert_difference('List.count') do
      post :create, project_id: @project, randomization_scheme_id: @randomization_scheme, list: { name: @list.name }
    end

    assert_redirected_to project_randomization_scheme_list_path(assigns(:project), assigns(:randomization_scheme), assigns(:list))
  end

  test "should show list" do
    get :show, project_id: @project, randomization_scheme_id: @randomization_scheme, id: @list
    assert_response :success
  end

  test "should get edit" do
    get :edit, project_id: @project, randomization_scheme_id: @randomization_scheme, id: @list
    assert_response :success
  end

  test "should update list" do
    patch :update, project_id: @project, randomization_scheme_id: @randomization_scheme, id: @list, list: { name: @list.name }
    assert_redirected_to project_randomization_scheme_list_path(assigns(:project), assigns(:randomization_scheme), assigns(:list))
  end

  test "should destroy list" do
    assert_difference('List.current.count', -1) do
      delete :destroy, project_id: @project, randomization_scheme_id: @randomization_scheme, id: @list
    end

    assert_redirected_to project_randomization_scheme_lists_path(assigns(:project), assigns(:randomization_scheme))
  end
end
