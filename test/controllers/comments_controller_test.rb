require 'test_helper'

class CommentsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @comment = comments(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:comments)
  end

  test "should create comment" do
    assert_difference('Comment.count') do
      post :create, sheet_id: @comment.sheet_id, comment: { description: @comment.description }, format: 'js'
    end

    assert_not_nil assigns(:sheet)
    assert_not_nil assigns(:sheet)
    assert_equal users(:valid).id, assigns(:comment).user_id

    assert_template 'create'
    assert_response :success
  end

  test "should show comment" do
    get :show, id: @comment
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @comment
    assert_response :success
  end

  test "should update comment" do
    patch :update, id: @comment, sheet_id: @comment.sheet_id, comment: { description: @comment.description }
    assert_redirected_to comment_path(assigns(:comment))
  end

  test "should destroy comment" do
    assert_difference('Comment.current.count', -1) do
      delete :destroy, id: @comment, format: 'js'
    end

    assert_template 'destroy'
    assert_response :success
  end
end
