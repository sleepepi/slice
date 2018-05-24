# frozen_string_literal: true

require "test_helper"

# Tests to make sure project owners, editors, and viewers can leave comments on
# sheets.
class CommentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @comment = comments(:one)
    @project_editor = users(:project_one_editor)
  end

  def comment_params
    { description: "I made a comment." }
  end

  test "should create comment" do
    login(users(:regular))
    assert_difference("Comment.count") do
      post comments_url(format: "js"), params: {
        sheet_id: @comment.sheet_id,
        comment: comment_params
      }
    end
    assert_not_nil assigns(:sheet)
    assert_not_nil assigns(:comment)
    assert_equal users(:regular).id, assigns(:comment).user_id
    assert_template "index"
    assert_response :success
  end

  test "should not create comment with blank description" do
    login(users(:regular))
    assert_difference("Comment.count", 0) do
      post comments_url(format: "js"), params: {
        sheet_id: @comment.sheet_id,
        comment: comment_params.merge(description: "")
      }
    end
    assert_not_nil assigns(:sheet)
    assert_not_nil assigns(:comment)
    assert_equal ["can't be blank"], assigns(:comment).errors[:description]
    assert_template "edit"
    assert_response :success
  end

  test "should show comment as ajax" do
    login(users(:regular))
    get comment_url(@comment, format: "js"), params: {
      include_name: "0",
      number: @comment.number
    }, xhr: true
    assert_response :success
  end

  test "should redirect to comment on sheet" do
    login(users(:regular))
    get comment_url(@comment), params: {
      include_name: "0",
      number: @comment.number
    }
    assert_redirected_to project_sheet_path(
      assigns(:comment).project,
      assigns(:comment).sheet,
      anchor: "comment-#{assigns(:comment).number}"
    )
  end

  test "should get edit" do
    login(users(:regular))
    get edit_comment_url(@comment, format: "js"), params: {
      include_name: "0", number: @comment.number
    }, xhr: true
    assert_template "edit"
    assert_response :success
  end

  test "should get edit as project editor" do
    login(@project_editor)
    get edit_comment_url(@comment, format: "js"), params: {
      include_name: "0", number: @comment.number
    }, xhr: true
    assert_template "edit"
    assert_response :success
  end

  test "should update comment" do
    login(users(:regular))
    patch comment_url(@comment, format: "js"), params: {
      comment: comment_params
    }
    assert_not_nil assigns(:comment)
    assert_template "show"
    assert_response :success
  end

  test "should update comment as project editor" do
    login(@project_editor)
    patch comment_url(@comment, format: "js"), params: {
      comment: comment_params
    }
    assert_not_nil assigns(:comment)
    assert_template "show"
    assert_response :success
  end

  test "should not update comment with blank description" do
    login(users(:regular))
    patch comment_url(@comment, format: "js"), params: {
      comment: comment_params.merge(description: "")
    }
    assert_not_nil assigns(:comment)
    assert_equal ["can't be blank"], assigns(:comment).errors[:description]
    assert_template "edit"
    assert_response :success
  end

  test "should destroy comment" do
    login(users(:regular))
    assert_difference("Notification.count", -1) do
      assert_difference("Comment.current.count", -1) do
        delete comment_url(@comment, format: "js")
      end
    end
    assert_template "destroy"
    assert_response :success
  end
end
