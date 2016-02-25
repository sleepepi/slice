# frozen_string_literal: true

require 'test_helper'

# Tests the creation and modification of comments added to adverse events
class AdverseEventCommentsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @project = projects(:one)
    @adverse_event = adverse_events(:one)
    @adverse_event_comment = adverse_event_comments(:one)
  end

  test 'should create adverse event comment as project editor' do
    assert_difference('AdverseEventComment.count') do
      post :create, project_id: @project, adverse_event_id: @adverse_event,
                    adverse_event_comment: {
                      comment_type: @adverse_event_comment.comment_type,
                      description: @adverse_event_comment.description
                    },
                    format: 'js'
    end
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:adverse_event)
    assert_not_nil assigns(:adverse_event_comment)
    assert_template 'index'
    assert_response :success
  end

  test 'should create adverse event comment as site editor' do
    login(users(:site_one_editor))
    assert_difference('AdverseEventComment.count') do
      post :create, project_id: @project, adverse_event_id: @adverse_event,
                    adverse_event_comment: {
                      comment_type: @adverse_event_comment.comment_type,
                      description: @adverse_event_comment.description
                    },
                    format: 'js'
    end
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:adverse_event)
    assert_not_nil assigns(:adverse_event_comment)
    assert_template 'index'
    assert_response :success
  end

  test 'should not create adverse event comment with blank comment' do
    assert_difference('AdverseEventComment.count', 0) do
      post :create, project_id: @project, adverse_event_id: @adverse_event,
                    adverse_event_comment: {
                      comment_type: 'commented',
                      description: ''
                    },
                    format: 'js'
    end
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:adverse_event)
    assert_not_nil assigns(:adverse_event_comment)
    assert assigns(:adverse_event_comment).errors.size > 0
    assert_equal ["can't be blank"], assigns(:adverse_event_comment).errors[:description]
    assert_template 'edit'
    assert_response :success
  end

  test 'should not create adverse event comment as site viewer' do
    login(users(:site_one_viewer))
    assert_difference('AdverseEventComment.count', 0) do
      post :create, project_id: @project, adverse_event_id: @adverse_event,
                    adverse_event_comment: {
                      comment_type: @adverse_event_comment.comment_type,
                      description: @adverse_event_comment.description
                    },
                    format: 'js'
    end
    assert_nil assigns(:project)
    assert_nil assigns(:adverse_event)
    assert_nil assigns(:adverse_event_comment)
    assert_response :success
  end

  test 'should show adverse event comment as project editor' do
    xhr :get, :show, project_id: @project, adverse_event_id: @adverse_event, id: @adverse_event_comment, format: 'js'
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:adverse_event)
    assert_not_nil assigns(:adverse_event_comment)
    assert_template 'show'
    assert_response :success
  end

  test 'should show adverse event comment as site editor' do
    login(users(:site_one_editor))
    xhr :get, :show, project_id: @project, adverse_event_id: @adverse_event, id: @adverse_event_comment, format: 'js'
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:adverse_event)
    assert_not_nil assigns(:adverse_event_comment)
    assert_template 'show'
    assert_response :success
  end

  test 'should not show adverse event comment as site viewer' do
    login(users(:site_one_viewer))
    xhr :get, :show, project_id: @project, adverse_event_id: @adverse_event, id: @adverse_event_comment, format: 'js'
    assert_nil assigns(:project)
    assert_nil assigns(:adverse_event)
    assert_nil assigns(:adverse_event_comment)
    assert_response :success
  end

  test 'should get edit as project editor' do
    xhr :get, :edit, project_id: @project, adverse_event_id: @adverse_event, id: @adverse_event_comment, format: 'js'
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:adverse_event)
    assert_not_nil assigns(:adverse_event_comment)
    assert_response :success
  end

  test 'should get edit as site editor' do
    login(users(:site_one_editor))
    xhr :get, :edit, project_id: @project, adverse_event_id: @adverse_event, id: @adverse_event_comment, format: 'js'
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:adverse_event)
    assert_not_nil assigns(:adverse_event_comment)
    assert_response :success
  end

  test 'should not get edit as site viewer' do
    login(users(:site_one_viewer))
    xhr :get, :edit, project_id: @project, adverse_event_id: @adverse_event, id: @adverse_event_comment, format: 'js'
    assert_nil assigns(:project)
    assert_nil assigns(:adverse_event)
    assert_nil assigns(:adverse_event_comment)
    assert_response :success
  end

  test 'should update adverse event comment as project editor' do
    patch :update, project_id: @project, adverse_event_id: @adverse_event, id: @adverse_event_comment,
                   adverse_event_comment: {
                     comment_type: @adverse_event_comment.comment_type,
                     description: @adverse_event_comment.description
                   }, format: 'js'
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:adverse_event)
    assert_not_nil assigns(:adverse_event_comment)
    assert_template 'show'
    assert_response :success
  end

  test 'should update adverse event comment as site editor' do
    login(users(:site_one_editor))
    patch :update, project_id: @project, adverse_event_id: @adverse_event, id: @adverse_event_comment,
                   adverse_event_comment: {
                     comment_type: @adverse_event_comment.comment_type,
                     description: @adverse_event_comment.description
                   }, format: 'js'
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:adverse_event)
    assert_not_nil assigns(:adverse_event_comment)
    assert_template 'show'
    assert_response :success
  end

  test 'should not update adverse event comment with blank description' do
    patch :update, project_id: @project, adverse_event_id: @adverse_event, id: adverse_event_comments(:two),
                   adverse_event_comment: { description: '' }, format: 'js'
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:adverse_event)
    assert_not_nil assigns(:adverse_event_comment)
    assert assigns(:adverse_event_comment).errors.size > 0
    assert_equal ["can't be blank"], assigns(:adverse_event_comment).errors[:description]
    assert_template 'edit'
    assert_response :success
  end

  test 'should not update adverse event comment as site viewer' do
    login(users(:site_one_viewer))
    patch :update, project_id: @project, adverse_event_id: @adverse_event, id: @adverse_event_comment,
                   adverse_event_comment: {
                     comment_type: @adverse_event_comment.comment_type,
                     description: @adverse_event_comment.description
                   }, format: 'js'
    assert_nil assigns(:project)
    assert_nil assigns(:adverse_event)
    assert_nil assigns(:adverse_event_comment)
    assert_response :success
  end

  test 'should destroy adverse event comment as project editor' do
    assert_difference('AdverseEventComment.current.count', -1) do
      delete :destroy, project_id: @project, adverse_event_id: @adverse_event, id: @adverse_event_comment, format: 'js'
    end
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:adverse_event)
    assert_not_nil assigns(:adverse_event_comment)
    assert_template 'index'
    assert_response :success
  end

  test 'should destroy adverse event comment as site editor' do
    login(users(:site_one_editor))
    assert_difference('AdverseEventComment.current.count', -1) do
      delete :destroy, project_id: @project, adverse_event_id: @adverse_event, id: @adverse_event_comment, format: 'js'
    end
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:adverse_event)
    assert_not_nil assigns(:adverse_event_comment)
    assert_template 'index'
    assert_response :success
  end

  test 'should destroy adverse event comment as site viewer' do
    login(users(:site_one_viewer))
    assert_difference('AdverseEventComment.current.count', 0) do
      delete :destroy, project_id: @project, adverse_event_id: @adverse_event, id: @adverse_event_comment, format: 'js'
    end
    assert_nil assigns(:project)
    assert_nil assigns(:adverse_event)
    assert_nil assigns(:adverse_event_comment)
    assert_response :success
  end
end
