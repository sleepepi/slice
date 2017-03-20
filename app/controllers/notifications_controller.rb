# frozen_string_literal: true

# Allows users to be notified inside the web application of new changes to
# adverse events, new comments on sheets, and completed tablet handoffs.
class NotificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_notification_or_redirect, only: [:show, :update]
  before_action :find_viewable_project_or_redirect, only: [:mark_all_as_read]

  # GET /notifications
  def index
    @notifications = if params[:all] == '1'
                       current_user.notifications.where('notifications.created_at > ?', Time.zone.now - 7.days)
                     else
                       current_user.notifications.where(read: false)
                     end
  end

  # GET /notifications/1
  def show
    @notification.update read: true
    redirect_to notification_redirect_path
  end

  # PATCH /notifications/1.js
  def update
    @notification.update(notification_params)
    render :show
  end

  # PATCH /notifications/mark_all_as_read
  def mark_all_as_read
    notification_ids = current_user.notifications.where(project: @project, read: false).pluck(:id)
    current_user.notifications.where(id: notification_ids).update_all(read: true)
    @notifications = current_user.notifications.where(id: notification_ids)
  end

  private

  def find_notification_or_redirect
    @notification = current_user.notifications.find_by(id: params[:id])
    redirect_to notifications_path unless @notification
  end

  def notification_params
    params.require(:notification).permit(:read)
  end

  def notification_redirect_path
    return [@notification.project, @notification.adverse_event] if @notification.adverse_event
    return @notification.comment if @notification.comment
    return [@notification.project, @notification.export] if @notification.export
    return subject_event_redirect_path if @notification.handoff
    return [@notification.project, @notification.sheet] if @notification.sheet
    return [@notification.project, @notification.sheet_unlock_request.sheet] if @notification.sheet_unlock_request
    notifications_path
  end

  def subject_event_redirect_path
    event_project_subject_path(
      @notification.project, @notification.handoff.subject_event.subject,
      event_id: @notification.handoff.subject_event.event,
      subject_event_id: @notification.handoff.subject_event.id,
      event_date: @notification.handoff.subject_event.event_date_to_param
    )
  end
end
