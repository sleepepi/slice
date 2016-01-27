# frozen_string_literal: true

class EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_editable_project, only: [:index, :show, :new, :edit, :create, :update, :destroy, :add_design]
  before_action :redirect_without_project, only: [:index, :show, :new, :edit, :create, :update, :destroy, :add_design]
  before_action :set_editable_event, only: [:show, :edit, :update, :destroy]
  before_action :redirect_without_event, only: [:show, :edit, :update, :destroy]

  # POST /events/add_design.js
  def add_design
  end

  # GET /events
  def index
    @order = scrub_order(Event, params[:order], 'events.position')
    @events = @project.events.search(params[:search]).order(@order).page(params[:page]).per(40)
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
      render action: 'new'
    end
  end

  # PUT /events/1
  def update
    if @event.update(event_params)
      redirect_to [@project, @event], notice: 'Event was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /events/1
  def destroy
    @event.destroy
    redirect_to project_events_path(@project)
  end

  private

  def set_editable_event
    @event = @project.events.find_by_param(params[:id])
  end

  def redirect_without_event
    empty_response_or_root_path(project_events_path(@project)) unless @event
  end

  def event_params
    params.require(:event).permit(
      :name, :slug, :description, :position, :scheduled, :archived,
      { design_hashes: [:design_id, :handoff_enabled] }
    )
  end
end
