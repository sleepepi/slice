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

  layout "layouts/full_page_sidebar"

  # GET /projects/:project_id/adverse-events/export
  def export
    @export = \
      current_user
      .exports
      .where(project_id: @project.id, name: @project.name_with_date_for_file, total_steps: 1)
      .create(include_csv_labeled: true, include_adverse_events: true, filters: "has:adverse-events")
    @export.generate_export_in_background!
    redirect_to [@project, @export]
  end

  # GET /projects/:project_id/adverse-events
  def index
    scope = viewable_adverse_events
    scope = scope_includes(scope)
    scope = scope_filter(scope)
    @adverse_events = scope_order(scope).page(params[:page]).per(40)
  end

  # # GET /projects/:project_id/adverse-events/1
  # def show
  # end

  # GET /projects/:project_id/adverse-events/new
  def new
    @adverse_event = viewable_adverse_events.new(subject_code: params[:subject_code])
  end

  # # GET /projects/:project_id/adverse-events/1/edit
  # def edit
  # end

  # POST /adverse-events
  def create
    @adverse_event = current_user.adverse_events.where(project_id: @project.id).new(adverse_event_params)
    if @adverse_event.save
      @adverse_event.create_notifications
      @adverse_event.send_email_in_background
      @adverse_event.generate_number!
      redirect_to [@project, @adverse_event], notice: "Adverse event was successfully created."
    else
      render :new
    end
  end

  # PATCH /projects/:project_id/adverse-events/1
  def update
    if @adverse_event.update(adverse_event_params)
      redirect_to [@project, @adverse_event], notice: "Adverse event was successfully updated."
    else
      render :edit
    end
  end

  # POST /projects/:project_id/adverse-events/1/set_shareable_link
  def set_shareable_link
    @adverse_event.set_token
    redirect_to [@project, @adverse_event], notice: "Shareable link was successfully created."
  end

  # POST /projects/:project_id/adverse-events/1/remove_shareable_link
  def remove_shareable_link
    @adverse_event.update authentication_token: nil
    redirect_to [@project, @adverse_event], notice: "Shareable link was successfully removed."
  end

  # DELETE /projects/:project_id/adverse-events/1
  def destroy
    @adverse_event.destroy
    redirect_to project_adverse_events_path(@project), notice: "Adverse event was successfully deleted."
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

  def scope_includes(scope)
    scope.includes(:subject, { subject: :site }, :user)
  end

  def scope_filters_extra(scope)
    scope = scope.with_site(params[:site_id]) if params[:site_id].present?
    scope = scope.where(closed: params[:status] == "closed") if params[:status].present?
    scope
  end

  def scope_filter(scope)
    scope = scope_filters_extra(scope)
    [:user_id].each do |key|
      scope = scope.where(key => params[key]) if params[key].present?
    end
    scope.search(params[:search])
  end

  def scope_order(scope)
    @order = params[:order]
    scope.order(AdverseEvent::ORDERS[params[:order]] || AdverseEvent::DEFAULT_ORDER)
  end
end
