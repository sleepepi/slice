# frozen_string_literal: true

# Tracks updates to adverse events.
class AdverseEventsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_viewable_project_or_redirect, only: [:index, :show, :forms]
  before_action :find_editable_project_or_redirect, only: [:export]
  before_action :find_editable_project_or_editable_site_or_redirect, only: [
    :new, :create, :edit, :update, :destroy, :set_shareable_link, :remove_shareable_link
  ]
  before_action :redirect_blinded_users
  before_action :find_viewable_adverse_event_or_redirect, only: [:show, :forms]
  before_action :find_editable_adverse_event_or_redirect, only: [
    :edit, :update, :destroy, :set_shareable_link, :remove_shareable_link
  ]

  # GET /adverse-events/export
  def export
    @export = current_user.exports
                          .where(project_id: @project.id, name: @project.name_with_date_for_file, total_steps: 1)
                          .create(include_csv_labeled: true, include_adverse_events: true)
    @export.generate_export_in_background!
    redirect_to [@project, @export]
  end

  # GET /adverse-events
  def index
    adverse_event_scope = viewable_adverse_events.search(params[:search])
    adverse_event_scope = adverse_event_scope.with_site(params[:site_id]) if params[:site_id].present?
    adverse_event_scope = adverse_event_scope.where(user_id: params[:reported_by_id]) if params[:reported_by_id].present?
    adverse_event_scope = adverse_event_scope.where(closed: params[:status] == 'closed') if params[:status].present?
    @order = params[:order]
    case params[:order]
    when 'adverse_events.reported_by'
      adverse_event_scope = adverse_event_scope.includes(:user).order('users.last_name, users.first_name')
    when 'adverse_events.reported_by desc'
      adverse_event_scope = adverse_event_scope.includes(:user).order('users.last_name desc, users.first_name desc')
    when 'adverse_events.site_name'
      adverse_event_scope = adverse_event_scope.includes(subject: :site).order('sites.name')
    when 'adverse_events.site_name desc'
      adverse_event_scope = adverse_event_scope.includes(subject: :site).order('sites.name desc')
    when 'adverse_events.subject_code'
      adverse_event_scope = adverse_event_scope.includes(:subject).order('subjects.subject_code')
    when 'adverse_events.subject_code desc'
      adverse_event_scope = adverse_event_scope.includes(:subject).order('subjects.subject_code desc')
    else
      @order = scrub_order(AdverseEvent, params[:order], 'adverse_events.created_at desc')
      adverse_event_scope = adverse_event_scope.order(@order)
    end
    @adverse_events = adverse_event_scope.page(params[:page]).per(40)
  end

  # # GET /adverse-events/1
  # def show
  # end

  # GET /adverse-events/new
  def new
    @adverse_event = viewable_adverse_events.new(subject_code: params[:subject_code])
  end

  # # GET /adverse-events/1/edit
  # def edit
  # end

  # POST /adverse-events
  def create
    @adverse_event = current_user.adverse_events.where(project_id: @project.id).new(adverse_event_params)
    if @adverse_event.save
      @adverse_event.create_notifications
      @adverse_event.send_email_in_background
      redirect_to [@project, @adverse_event], notice: 'Adverse event was successfully created.'
    else
      render :new
    end
  end

  # PATCH /adverse-events/1
  def update
    if @adverse_event.update(adverse_event_params)
      redirect_to [@project, @adverse_event], notice: 'Adverse event was successfully updated.'
    else
      render :edit
    end
  end

  # POST /adverse-events/1/set_shareable_link
  def set_shareable_link
    @adverse_event.set_token
    redirect_to [@project, @adverse_event], notice: 'Shareable link was successfully created.'
  end

  # POST /adverse-events/1/remove_shareable_link
  def remove_shareable_link
    @adverse_event.update authentication_token: nil
    redirect_to [@project, @adverse_event], notice: 'Shareable link was successfully removed.'
  end

  # DELETE /adverse-events/1
  def destroy
    @adverse_event.destroy
    redirect_to project_adverse_events_path(@project), notice: 'Adverse event was successfully deleted.'
  end

  private

  def viewable_adverse_events
    current_user.all_viewable_adverse_events.where(project_id: @project.id)
  end

  def find_viewable_adverse_event_or_redirect
    @adverse_event = viewable_adverse_events.find_by(id: params[:id])
    redirect_without_adverse_event
  end

  def find_editable_adverse_event_or_redirect
    @adverse_event = current_user.all_adverse_events.find_by(id: params[:id])
    redirect_without_adverse_event
  end

  def redirect_without_adverse_event
    empty_response_or_root_path(project_adverse_events_path(@project)) unless @adverse_event
  end

  def adverse_event_params
    params.require(:adverse_event).permit(
      :description, :closed,
      # Attribute Accessor
      :subject_code, :event_date
    )
  end
end
