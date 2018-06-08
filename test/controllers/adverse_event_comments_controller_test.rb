# frozen_string_literal: true

require "test_helper"

# Tests the creation and modification of comments added to adverse events.
class AdverseEventCommentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project_editor = users(:regular)
    @site_editor = users(:site_one_editor)
    @site_viewer = users(:site_one_viewer)
    @project = projects(:one)
    @adverse_event = adverse_events(:one)
    @adverse_event_comment = adverse_event_comments(:one)
  end

  def adverse_event_comment_params
    {
      comment_type: "reopened",
      description: "Reopened AE"
    }
  end

  test "should create adverse event comment as project editor" do
    login(@project_editor)
    assert_difference("AdverseEventComment.count") do
      post project_adverse_event_adverse_event_comments_url(@project, @adverse_event, format: "js"), params: {
        adverse_event_comment: adverse_event_comment_params
      }
    end
    assert_template "index"
    assert_response :success
  end

  test "should create adverse event comment as site editor" do
    login(@site_editor)
    assert_difference("AdverseEventComment.count") do
      post project_adverse_event_adverse_event_comments_url(@project, @adverse_event, format: "js"), params: {
        adverse_event_comment: adverse_event_comment_params
      }
    end
    assert_template "index"
    assert_response :success
  end

  test "should not create adverse event comment with blank comment" do
    login(@project_editor)
    assert_difference("AdverseEventComment.count", 0) do
      post project_adverse_event_adverse_event_comments_url(@project, @adverse_event, format: "js"), params: {
        adverse_event_comment: adverse_event_comment_params.merge(comment_type: "commented", description: "")
      }
    end
    assert_equal ["can't be blank"], assigns(:adverse_event_comment).errors[:description]
    assert_template "edit"
    assert_response :success
  end

  test "should not create adverse event comment as site viewer" do
    login(@site_viewer)
    assert_difference("AdverseEventComment.count", 0) do
      post project_adverse_event_adverse_event_comments_url(@project, @adverse_event, format: "js"), params: {
        adverse_event_comment: adverse_event_comment_params
      }
    end
    assert_response :success
  end

  test "should show adverse event comment as project editor" do
    login(@project_editor)
    get project_adverse_event_adverse_event_comment_url(
      @project, @adverse_event, @adverse_event_comment, format: "js"
    ), xhr: true
    assert_template "show"
    assert_response :success
  end

  test "should show adverse event comment as site editor" do
    login(@site_editor)
    get project_adverse_event_adverse_event_comment_url(
      @project, @adverse_event, @adverse_event_comment, format: "js"
    ), xhr: true
    assert_template "show"
    assert_response :success
  end

  test "should not show adverse event comment as site viewer" do
    login(@site_viewer)
    get project_adverse_event_adverse_event_comment_url(
      @project, @adverse_event, @adverse_event_comment, format: "js"
    ), xhr: true
    assert_response :success
  end

  test "should get edit as project editor" do
    login(@project_editor)
    get edit_project_adverse_event_adverse_event_comment_url(
      @project, @adverse_event, @adverse_event_comment, format: "js"
    ), xhr: true
    assert_response :success
  end

  test "should get edit as site editor" do
    login(@site_editor)
    get edit_project_adverse_event_adverse_event_comment_url(
      @project, @adverse_event, @adverse_event_comment, format: "js"
    ), xhr: true
    assert_response :success
  end

  test "should not get edit as site viewer" do
    login(@site_viewer)
    get edit_project_adverse_event_adverse_event_comment_url(
      @project, @adverse_event, @adverse_event_comment, format: "js"
    ), xhr: true
    assert_response :success
  end

  test "should update adverse event comment as project editor" do
    login(@project_editor)
    patch project_adverse_event_adverse_event_comment_url(
      @project, @adverse_event, @adverse_event_comment, format: "js"
    ), params: { adverse_event_comment: adverse_event_comment_params }
    assert_template "show"
    assert_response :success
  end

  test "should update adverse event comment as site editor" do
    login(@site_editor)
    patch project_adverse_event_adverse_event_comment_url(
      @project, @adverse_event, @adverse_event_comment, format: "js"
    ), params: { adverse_event_comment: adverse_event_comment_params }
    assert_template "show"
    assert_response :success
  end

  test "should not update adverse event comment with blank description" do
    login(@project_editor)
    patch project_adverse_event_adverse_event_comment_url(
      @project, @adverse_event, adverse_event_comments(:two), format: "js"
    ), params: { adverse_event_comment: { comment_type: "commented", description: "" } }
    assert_equal ["can't be blank"], assigns(:adverse_event_comment).errors[:description]
    assert_template "edit"
    assert_response :success
  end

  test "should not update adverse event comment as site viewer" do
    login(@site_viewer)
    patch project_adverse_event_adverse_event_comment_url(
      @project, @adverse_event, @adverse_event_comment, format: "js"
    ), params: { adverse_event_comment: adverse_event_comment_params }
    assert_response :success
  end

  test "should destroy adverse event comment as project editor" do
    login(@project_editor)
    assert_difference("AdverseEventComment.current.count", -1) do
      delete project_adverse_event_adverse_event_comment_url(
        @project, @adverse_event, @adverse_event_comment, format: "js"
      )
    end
    assert_template "index"
    assert_response :success
  end

  test "should destroy adverse event comment as site editor" do
    login(@site_editor)
    assert_difference("AdverseEventComment.current.count", -1) do
      delete project_adverse_event_adverse_event_comment_url(
        @project, @adverse_event, @adverse_event_comment, format: "js"
      )
    end
    assert_template "index"
    assert_response :success
  end

  test "should destroy adverse event comment as site viewer" do
    login(@site_viewer)
    assert_difference("AdverseEventComment.current.count", 0) do
      delete project_adverse_event_adverse_event_comment_url(
        @project, @adverse_event, @adverse_event_comment, format: "js"
      )
    end
    assert_response :success
  end
end
