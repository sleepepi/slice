require 'test_helper'

class CommentsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @comment = comments(:one)
  end

  test 'should create comment' do
    assert_difference('Comment.count') do
      post :create, sheet_id: @comment.sheet_id, comment: { description: @comment.description }, format: 'js'
    end

    assert_not_nil assigns(:sheet)
    assert_not_nil assigns(:comment)
    assert_equal users(:valid).id, assigns(:comment).user_id

    assert_template 'index'
    assert_response :success
  end

  test 'should not create comment with blank description' do
    assert_difference('Comment.count', 0) do
      post :create, sheet_id: @comment.sheet_id, comment: { description: '' }, format: 'js'
    end

    assert_not_nil assigns(:sheet)
    assert_not_nil assigns(:comment)

    assert assigns(:comment).errors.size > 0
    assert_equal ["can't be blank"], assigns(:comment).errors[:description]
    assert_template 'edit'
    assert_response :success
  end

  test 'should show comment' do
    xhr :get, :show, id: @comment, include_name: '0', number: @comment.number, format: 'js'
    assert_response :success
  end

  test 'should get edit' do
    xhr :get, :edit, id: @comment, include_name: '0', number: @comment.number, format: 'js'
    assert_response :success
  end

  test 'should update comment' do
    patch :update, id: @comment, comment: { description: @comment.description }, format: 'js'
    assert_not_nil assigns(:comment)
    assert_template 'show'
    assert_response :success
  end

  test 'should not update comment with blank description' do
    patch :update, id: @comment, comment: { description: '' }, format: 'js'

    assert_not_nil assigns(:comment)

    assert assigns(:comment).errors.size > 0
    assert_equal ["can't be blank"], assigns(:comment).errors[:description]
    assert_template 'edit'
  end

  test 'should destroy comment' do
    assert_difference('Comment.current.count', -1) do
      delete :destroy, id: @comment, format: 'js'
    end

    assert_template 'destroy'
    assert_response :success
  end
end
