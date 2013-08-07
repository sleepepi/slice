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

  # test "should get new" do
  #   get :new, sheet_id: @comment.sheet_id
  #   assert_response :success
  # end

  test "should create comment" do
    assert_difference('Comment.count') do
      post :create, sheet_id: @comment.sheet_id, comment: { description: @comment.description }, format: 'js'
    end

    assert_not_nil assigns(:sheet)
    assert_not_nil assigns(:comment)
    assert_equal users(:valid).id, assigns(:comment).user_id

    assert_template 'create'
    assert_response :success
  end

  test "should not create comment with blank description" do
    assert_difference('Comment.count', 0) do
      post :create, sheet_id: @comment.sheet_id, comment: { description: '' }, format: 'js'
    end

    assert_not_nil assigns(:sheet)
    assert_not_nil assigns(:comment)

    assert assigns(:comment).errors.size > 0
    assert_equal ["can't be blank"], assigns(:comment).errors[:description]
    assert_template 'create'
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
    patch :update, id: @comment, comment: { description: @comment.description }
    assert_redirected_to project_sheet_path(assigns(:comment).sheet.project, assigns(:comment).sheet)
  end

  test "should not update comment with blank description" do
    patch :update, id: @comment, comment: { description: '' }

    assert_not_nil assigns(:comment)

    assert assigns(:comment).errors.size > 0
    assert_equal ["can't be blank"], assigns(:comment).errors[:description]
    assert_template 'edit'
  end

  test "should destroy comment" do
    assert_difference('Comment.current.count', -1) do
      delete :destroy, id: @comment, format: 'js'
    end

    assert_template 'destroy'
    assert_response :success
  end
end
