require 'test_helper'

class NotificationsControllerTest < ActionController::TestCase
  test 'should get index' do
    login(users(:valid))
    get :index
    assert_response :success
    assert_not_nil assigns(:notifications)
  end

  test 'should show comment notification' do
    login(users(:valid))
    get :show, id: notifications(:comment)
    assert_not_nil assigns(:notification)
    assert_equal true, assigns(:notification).read
    assert_redirected_to assigns(:notification).comment
  end

  test 'should show adverse event notification' do
    login(users(:valid))
    get :show, id: notifications(:adverse_event)
    assert_not_nil assigns(:notification)
    assert_equal true, assigns(:notification).read
    assert_redirected_to [assigns(:notification).project, assigns(:notification).adverse_event]
  end

  test 'should show handoff notification' do
    login(users(:valid))
    get :show, id: notifications(:handoff)
    assert_not_nil assigns(:notification)
    assert_equal true, assigns(:notification).read
    assert_redirected_to event_project_subject_path(assigns(:notification).project, assigns(:notification).handoff.subject_event.subject, event_id: assigns(:notification).handoff.subject_event.event, subject_event_id: assigns(:notification).handoff.subject_event.id, event_date: assigns(:notification).handoff.subject_event.event_date_to_param)
  end

  test 'should not show notification without valid id' do
    login(users(:valid))
    get :show, id: -1
    assert_nil assigns(:notification)
    assert_redirected_to notifications_path
  end

  test 'should update notification' do
    login(users(:valid))
    patch :update, id: notifications(:comment), notification: { read: true }, format: 'js'
    assert_not_nil assigns(:notification)
    assert_equal true, assigns(:notification).read
    assert_template 'show'
    assert_response :success
  end

  test 'should mark all as read' do
    login(users(:valid))
    patch :mark_all_as_read, project_id: projects(:one), format: 'js'
    assert_equal 0, users(:valid).notifications.where(project_id: projects(:one), read: false).count
    assert_template 'mark_all_as_read'
    assert_response :success
  end
end
