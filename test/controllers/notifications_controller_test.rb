# frozen_string_literal: true

require "test_helper"

# Test that notifications can be viewed and marked as read.
class NotificationsControllerTest <  ActionDispatch::IntegrationTest
  setup do
    @regular_user = users(:valid)
  end

  test "should get index" do
    login(@regular_user)
    get notifications_url
    assert_response :success
  end

  test "should get all read index" do
    login(@regular_user)
    get notifications_url(all: "1")
    assert_response :success
  end

  test "should show comment notification" do
    login(@regular_user)
    get notification_url(notifications(:comment))
    assert_not_nil assigns(:notification)
    assert_equal true, assigns(:notification).read
    assert_redirected_to assigns(:notification).comment
  end

  test "should show adverse event notification" do
    login(@regular_user)
    get notification_url(notifications(:adverse_event))
    assert_not_nil assigns(:notification)
    assert_equal true, assigns(:notification).read
    assert_redirected_to [assigns(:notification).project, assigns(:notification).adverse_event]
  end

  test "should show export notification" do
    login(@regular_user)
    get notification_url(notifications(:export))
    assert_not_nil assigns(:notification)
    assert_equal true, assigns(:notification).read
    assert_redirected_to [assigns(:notification).project, assigns(:notification).export]
  end

  test "should show handoff notification" do
    login(@regular_user)
    get notification_url(notifications(:handoff))
    assert_not_nil assigns(:notification)
    assert_equal true, assigns(:notification).read
    assert_redirected_to event_project_subject_path(
      assigns(:notification).project,
      assigns(:notification).handoff.subject_event.subject,
      event_id: assigns(:notification).handoff.subject_event.event,
      subject_event_id: assigns(:notification).handoff.subject_event.id,
      event_date: assigns(:notification).handoff.subject_event.event_date_to_param
    )
  end

  test "should show sheet created notification" do
    login(@regular_user)
    get notification_url(notifications(:sheet_created))
    assert_not_nil assigns(:notification)
    assert_equal true, assigns(:notification).read
    assert_redirected_to [assigns(:notification).project, assigns(:notification).sheet]
  end

  test "should show blank notification and redirect" do
    login(@regular_user)
    get notification_url(notifications(:blank))
    assert_not_nil assigns(:notification)
    assert_equal true, assigns(:notification).read
    assert_redirected_to notifications_path
  end

  test "should not show notification without valid id" do
    login(@regular_user)
    get notification_url(-1)
    assert_nil assigns(:notification)
    assert_redirected_to notifications_path
  end

  test "should update notification" do
    login(@regular_user)
    patch notification_url(notifications(:comment), format: "js"), params: { notification: { read: true } }
    assert_not_nil assigns(:notification)
    assert_equal true, assigns(:notification).read
    assert_template "show"
    assert_response :success
  end

  test "should mark all as read" do
    login(@regular_user)
    patch mark_all_as_read_notifications_url(project_id: projects(:one).id, format: "js")
    assert_equal 0, @regular_user.notifications.where(project_id: projects(:one), read: false).count
    assert_template "mark_all_as_read"
    assert_response :success
  end

  test "should mark all as read without project" do
    login(@regular_user)
    patch mark_all_as_read_notifications_url(format: "js")
    assert_template "mark_all_as_read"
    assert_response :success
  end
end
