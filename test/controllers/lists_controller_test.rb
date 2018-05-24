# frozen_string_literal: true

require "test_helper"

# Tests to view and generate lists.
class ListsControllerTest < ActionController::TestCase
  setup do
    login(users(:regular))
    @project = projects(:one)
    @randomization_scheme = randomization_schemes(:one)
    @list = lists(:one)
  end

  test "should generate lists" do
    assert_difference("List.count", 2) do
      post :generate, params: { project_id: projects(:two), randomization_scheme_id: randomization_schemes(:three) }
    end
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:randomization_scheme)
    assert_redirected_to project_randomization_scheme_path(assigns(:project), assigns(:randomization_scheme))
  end

  test "should generate lists for minimization scheme with multiple sites" do
    assert_difference("List.count", 2) do
      post :generate, params: {
        project_id: projects(:two), randomization_scheme_id: randomization_schemes(:minimization)
      }
    end
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:randomization_scheme)
    assert_redirected_to project_randomization_scheme_path(assigns(:project), assigns(:randomization_scheme))
  end

  test "should generate single list for minimization scheme not stratifying by site" do
    assert_difference("List.count", 1) do
      post :generate, params: {
        project_id: projects(:two),
        randomization_scheme_id: randomization_schemes(:minimization_not_by_site)
      }
    end
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:randomization_scheme)
    assert_redirected_to project_randomization_scheme_path(assigns(:project), assigns(:randomization_scheme))
  end

  test "should not generate lists for scheme with existing randomizations" do
    assert_difference("List.count", 0) do
      post :generate, params: { project_id: projects(:one), randomization_scheme_id: randomization_schemes(:one) }
    end
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:randomization_scheme)
    assert_redirected_to project_randomization_scheme_path(assigns(:project), assigns(:randomization_scheme))
  end

  test "should expand lists for minimization scheme with multiple sites" do
    assert_difference("List.count", 2) do
      post :expand, params: {
        project_id: projects(:two), randomization_scheme_id: randomization_schemes(:minimization)
      }
    end
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:randomization_scheme)
    assert_redirected_to project_randomization_scheme_path(assigns(:project), assigns(:randomization_scheme))
  end

  test "should get index" do
    get :index, params: { project_id: @project, randomization_scheme_id: @randomization_scheme }
    assert_response :success
    assert_not_nil assigns(:lists)
  end

  test "should show list" do
    get :show, params: { project_id: @project, randomization_scheme_id: @randomization_scheme, id: @list }
    assert_response :success
  end
end
