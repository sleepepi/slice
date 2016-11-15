# frozen_string_literal: true

# Allows project editors to create events that are used to group together sets
# of designs.
class EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_editable_project_or_redirect
  before_action :find_event_or_redirect, only: [:show, :edit, :update, :destroy]
  before_action :redirect_without_event, only: [:show, :edit, :update, :destroy]

  # POST /events/add_design.js
  def add_design
  end

  # GET /events
  def index
    @order = scrub_order(Event, params[:order], 'events.position')
    @events = @project.events.blinding_scope(current_user)
                      .search(params[:search]).order(@order)
                      .page(params[:page]).per(40)
  end

  # GET /events/1
  def show
  end

  # GET /events/new
  def new
    @event = current_user.events.where(project_id: @project.id).new(position: (@project.events.count + 1) * 10)
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events
  def create
    @event = current_user.events.where(project_id: @project.id).new(event_params)
    if @event.save
      redirect_to [@project, @event], notice: 'Event was successfully created.'
    else
      render :new
    end
  end

  # PATCH /events/1
  # PATCH /events/1.js
  def update
    if @event.update(event_params)
      respond_to do |format|
        format.html { redirect_to [@project, @event], notice: 'Event was successfully updated.' }
        format.js
      end
    else
      render :edit
    end
  end

  # DELETE /events/1
  # DELETE /events/1.js
  def destroy
    @event.unlink_sheets_in_background!(current_user, request.remote_ip)
    @event.destroy
    respond_to do |format|
      format.html { redirect_to project_events_path(@project), notice: 'Event was successfully deleted.' }
      format.js
    end
  end

  private

  def find_event_or_redirect
    @event = current_user.all_events.where(project: @project).find_by_param params[:id]
    redirect_without_event
  end

  def redirect_without_event
    empty_response_or_root_path(project_events_path(@project)) unless @event
  end

  def event_params
    params.require(:event).permit(
      :name, :slug, :description, :position, :archived, :only_unblinded,
      design_hashes: [:design_id, :handoff_enabled]
    )
  end
end
