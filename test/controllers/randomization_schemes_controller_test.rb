require 'test_helper'

class RandomizationSchemesControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @project = projects(:one)
    @randomization_scheme = randomization_schemes(:one)
  end

  test "should get index" do
    get :index, project_id: @project
    assert_response :success
    assert_not_nil assigns(:randomization_schemes)
  end

  test "should get new" do
    get :new, project_id: @project
    assert_response :success
  end

  test "should create randomization_scheme" do
    assert_difference('RandomizationScheme.count') do
      post :create, project_id: @project, randomization_scheme: { name: "New Randomization Scheme", description: @randomization_scheme.description, published: @randomization_scheme.published, randomization_goal: @randomization_scheme.randomization_goal }
    end

    assert_redirected_to project_randomization_scheme_path(assigns(:project), assigns(:randomization_scheme))
  end

  test "should show randomization_scheme" do
    get :show, project_id: @project, id: @randomization_scheme
    assert_response :success
  end

  test "should get edit" do
    get :edit, project_id: @project, id: @randomization_scheme
    assert_response :success
  end

  test "should update randomization_scheme" do
    patch :update, project_id: @project, id: @randomization_scheme, randomization_scheme: { name: "Updated Randomization Scheme", description: @randomization_scheme.description, published: @randomization_scheme.published, randomization_goal: @randomization_scheme.randomization_goal }
    assert_redirected_to project_randomization_scheme_path(assigns(:project), assigns(:randomization_scheme))
  end

  test "should destroy randomization_scheme" do
    assert_difference('RandomizationScheme.current.count', -1) do
      delete :destroy, project_id: @project, id: @randomization_scheme
    end

    assert_redirected_to project_randomization_schemes_path(assigns(:project))
  end
end
