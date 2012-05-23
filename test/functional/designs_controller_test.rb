require 'test_helper'

class DesignsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @design = designs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:designs)
  end

  test "should get paginated index" do
    get :index, format: 'js'
    assert_not_nil assigns(:designs)
    assert_template 'index'
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create design" do
    assert_difference('Design.count') do
      post :create, design: { description: @design.description, name: 'Design Three' }
    end

    assert_redirected_to design_path(assigns(:design))
  end

  test "should show design" do
    get :show, id: @design
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @design
    assert_response :success
  end

  test "should update design" do
    put :update, id: @design, design: { description: @design.description, name: @design.name }
    assert_redirected_to design_path(assigns(:design))
  end

  test "should destroy design" do
    assert_difference('Design.current.count', -1) do
      delete :destroy, id: @design
    end

    assert_redirected_to designs_path
  end
end
