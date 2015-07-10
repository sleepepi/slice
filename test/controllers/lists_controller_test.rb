require 'test_helper'

class ListsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @project = projects(:one)
    @randomization_scheme = randomization_schemes(:one)
    @list = lists(:one)
  end

  test "should generate lists" do
    assert_difference('List.count', 2) do
      post :generate, project_id: projects(:two), randomization_scheme_id: randomization_schemes(:three)
    end
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:randomization_scheme)
    assert_redirected_to project_randomization_scheme_path(assigns(:project), assigns(:randomization_scheme))
  end

  test "should get index" do
    get :index, project_id: @project, randomization_scheme_id: @randomization_scheme
    assert_response :success
    assert_not_nil assigns(:lists)
  end

  test "should show list" do
    get :show, project_id: @project, randomization_scheme_id: @randomization_scheme, id: @list
    assert_response :success
  end
end
