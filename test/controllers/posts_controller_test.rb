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

  test "should not get index with invalid project" do
    get :index, project_id: -1
    assert_nil assigns(:posts)
    assert_redirected_to root_path
  end

  test "should get new" do
    get :new, project_id: @project
    assert_response :success
  end

  test "should create post" do
    assert_difference('Post.count') do
      post :create, project_id: @project, post: { name: @post.name, archived: @post.archived, description: @post.description }
    end

    assert_redirected_to project_post_path(assigns(:post).project, assigns(:post))
  end

  test "should not create post with blank name" do
    assert_difference('Post.count', 0) do
      post :create, project_id: @project, post: { name: '', archived: @post.archived, description: @post.description }
    end

    assert_not_nil assigns(:post)
    assert assigns(:post).errors.size > 0
    assert_equal ["can't be blank"], assigns(:post).errors[:name]
    assert_template 'new'
  end

  test "should not create post with invalid project" do
    assert_difference('Post.count', 0) do
      post :create, project_id: -1, post: { name: @post.name, archived: @post.archived, description: @post.description }
    end

    assert_nil assigns(:post)
    assert_nil assigns(:project)
    assert_redirected_to root_path
  end

  test "should show post" do
    get :show, id: @post, project_id: @project
    assert_not_nil assigns(:post)
    assert_response :success
  end

  test "should not show post with invalid project" do
    get :show, id: @post, project_id: -1
    assert_nil assigns(:post)
    assert_redirected_to root_path
  end

  test "should get edit" do
    get :edit, id: @post, project_id: @project
    assert_not_nil assigns(:post)
    assert_response :success
  end

  test "should not get edit with invalid project" do
    get :edit, id: @post, project_id: -1
    assert_nil assigns(:post)
    assert_redirected_to root_path
  end

  test "should update post" do
    put :update, id: @post, project_id: @project, post: { name: @post.name, archived: @post.archived, description: @post.description }
    assert_redirected_to project_post_path(assigns(:post).project, assigns(:post))
  end

  test "should not update post with blank name" do
    put :update, id: @post, project_id: @project, post: { name: '', archived: @post.archived, description: @post.description }

    assert_not_nil assigns(:post)
    assert assigns(:post).errors.size > 0
    assert_equal ["can't be blank"], assigns(:post).errors[:name]
    assert_template 'edit'
  end

  test "should not update post with invalid project" do
    put :update, id: @post, project_id: -1, post: { name: @post.name, archived: @post.archived, description: @post.description }

    assert_nil assigns(:post)
    assert_nil assigns(:project)
    assert_redirected_to root_path
  end

  test "should destroy post" do
    assert_difference('Post.current.count', -1) do
      delete :destroy, id: @post, project_id: @project
    end

    assert_not_nil assigns(:post)
    assert_not_nil assigns(:project)

    assert_redirected_to project_posts_path
  end

  test "should not destroy post with invalid project" do
    assert_difference('Post.current.count', 0) do
      delete :destroy, id: @post, project_id: -1
    end

    assert_nil assigns(:post)
    assert_nil assigns(:project)

    assert_redirected_to root_path
  end
end
