require 'test_helper'

class PostsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @project = projects(:one)
    @post = posts(:one)
  end

  test "should get index" do
    get :index, project_id: @project
    assert_response :success
    assert_not_nil assigns(:posts)
  end

  test "should get new" do
    get :new, project_id: @project
    assert_response :success
  end

  test "should create post" do
    assert_difference('Post.count') do
      post :create, project_id: @project, post: { archived: @post.archived, description: @post.description, name: @post.name }
    end

    assert_redirected_to project_post_path(assigns(:post).project, assigns(:post))
  end

  test "should show post" do
    get :show, id: @post, project_id: @project
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @post, project_id: @project
    assert_response :success
  end

  test "should update post" do
    put :update, id: @post, project_id: @project, post: { archived: @post.archived, description: @post.description, name: @post.name }
    assert_redirected_to project_post_path(assigns(:post).project, assigns(:post))
  end

  test "should destroy post" do
    assert_difference('Post.current.count', -1) do
      delete :destroy, id: @post, project_id: @project
    end

    assert_redirected_to project_posts_path
  end
end
