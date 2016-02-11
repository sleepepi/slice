# frozen_string_literal: true

# Allows users to be notified inside the web application of new changes to
# adverse events, new comments on sheets, and completed tablet handoffs
class NotificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_notification, only: [:show, :update]
  before_action :set_viewable_project, only: [:mark_all_as_read]

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
    if @notification.adverse_event
      redirect_to [@notification.project, @notification.adverse_event]
    elsif @notification.comment
      redirect_to @notification.comment
    elsif @notification.handoff
      redirect_to event_project_subject_path(@notification.project, @notification.handoff.subject_event.subject, event_id: @notification.handoff.subject_event.event, subject_event_id: @notification.handoff.subject_event.id, event_date: @notification.handoff.subject_event.event_date_to_param)
    else
      redirect_to notifications_path
    end
  end

  # PATCH /notifications/1.js
  def update
    @notification.update(notification_params)
    render :show
  end

  # PATCH /notifications/mark_all_as_read
  def mark_all_as_read
    if @project
      @notifications = current_user.notifications.where(project_id: @project.id)
      @notifications.update_all read: true
    else
      @notifications = Notification.none
    end
  end

  private

  def set_notification
    @notification = current_user.notifications.find_by_id params[:id]
    redirect_to notifications_path unless @notification
  end

  def notification_params
    params.require(:notification).permit(:read)
  end
end
