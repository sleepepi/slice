require 'test_helper'

class ProjectUsersControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @project_user = project_users(:one)
  end

  # test "should get index" do
  #   get :index
  #   assert_response :success
  #   assert_not_nil assigns(:project_users)
  # end
  #
  # test "should get new" do
  #   get :new
  #   assert_response :success
  # end

  test "should create project user" do
    assert_difference('ProjectUser.count') do
      post :create, project_user: { project_id: projects(:one).id, allow_editing: true }, librarians_text: users(:two).name + " <#{users(:two).email}>", format: 'js'
    end

    assert_not_nil assigns(:project_user)
    assert_template 'index'
  end

  test "should not create project user with invalid project id" do
    assert_difference('ProjectUser.count', 0) do
      post :create, project_user: { project_id: -1, allow_editing: true }, librarians_text: users(:two).name + " <#{users(:two).email}>", format: 'js'
    end

    assert_nil assigns(:project_user)
    assert_response :success
  end

  # test "should show project_user" do
  #   get :show, id: @project_user
  #   assert_response :success
  # end
  #
  # test "should get edit" do
  #   get :edit, id: @project_user
  #   assert_response :success
  # end
  #
  # test "should update project_user" do
  #   put :update, id: @project_user, project_user: @project_user.attributes
  #   assert_redirected_to project_user_path(assigns(:project_user))
  # end

  test "should destroy project user" do
    assert_difference('ProjectUser.count', -1) do
      delete :destroy, id: @project_user, format: 'js'
    end

    assert_not_nil assigns(:project)
    assert_template 'index'
  end

  test "should allow member to remove self from project" do
    assert_difference('ProjectUser.count', -1) do
      delete :destroy, id: project_users(:five), format: 'js'
    end

    assert_not_nil assigns(:project)
    assert_template 'index'
  end

  test "should destroy project user with invalid id" do
    assert_difference('ProjectUser.count', 0) do
      delete :destroy, id: -1, format: 'js'
    end

    assert_nil assigns(:project)
    assert_response :success
  end
end
