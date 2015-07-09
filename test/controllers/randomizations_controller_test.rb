require 'test_helper'

class RandomizationsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @project = projects(:one)
    @randomization = randomizations(:one)
  end

  test "should get index" do
    get :index, project_id: @project
    assert_response :success
    assert_not_nil assigns(:randomizations)
  end

  test "should show randomization" do
    get :show, project_id: @project, id: @randomization
    assert_response :success
  end

  test "should undo randomization" do
    patch :undo, project_id: @project, id: @randomization
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:randomization)
    assert_nil assigns(:randomization).subject_id
    assert_nil assigns(:randomization).randomized_by_id
    assert_nil assigns(:randomization).randomized_at
    assert_redirected_to project_randomization_path(assigns(:project), assigns(:randomization))
  end



  # test "should destroy randomization" do
  #   assert_difference('Randomization.current.count', -1) do
  #     delete :destroy, project_id: @project, id: @randomization
  #   end

  #   assert_redirected_to project_randomizations_path(assigns(:project))
  # end
end
