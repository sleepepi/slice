require 'test_helper'

class AdverseEventCommentsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @project = projects(:one)
    @adverse_event = adverse_events(:one)
    @adverse_event_comment = adverse_event_comments(:one)
  end

  test 'should create adverse event comment' do
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

  test 'should show adverse event comment' do
    xhr :get, :show, project_id: @project, adverse_event_id: @adverse_event, id: @adverse_event_comment, format: 'js'
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:adverse_event)
    assert_not_nil assigns(:adverse_event_comment)
    assert_template 'show'
    assert_response :success
  end

  test 'should get edit' do
    xhr :get, :edit, project_id: @project, adverse_event_id: @adverse_event, id: @adverse_event_comment, format: 'js'
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:adverse_event)
    assert_not_nil assigns(:adverse_event_comment)
    assert_response :success
  end

  test 'should update adverse event comment' do
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

  test 'should destroy adverse event comment' do
    assert_difference('AdverseEventComment.current.count', -1) do
      delete :destroy, project_id: @project, adverse_event_id: @adverse_event, id: @adverse_event_comment, format: 'js'
    end
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:adverse_event)
    assert_not_nil assigns(:adverse_event_comment)
    assert_template 'index'
    assert_response :success
  end
end
