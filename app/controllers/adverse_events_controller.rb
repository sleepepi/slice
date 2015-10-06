# Tracks updates to adverse events
class AdverseEventsController < ApplicationController
  before_action :authenticate_user!

  before_action :set_viewable_project,                  only: [:index, :show, :forms]
  before_action :set_editable_project_or_editable_site, only: [:new, :create, :edit, :update, :destroy]
  before_action :redirect_without_project

  before_action :redirect_blinded_users

  before_action :set_viewable_adverse_event,            only: [:show, :forms]
  before_action :set_editable_adverse_event,            only: [:edit, :update, :destroy]
  before_action :redirect_without_adverse_event,        only: [:show, :forms, :edit, :update, :destroy]

  # GET /adverse_events
  def index
    @order = scrub_order(AdverseEvent, params[:order], 'adverse_events.created_at DESC')
    @adverse_events = current_user.all_viewable_adverse_events
                      .where(project_id: @project.id)
                      .search(params[:search])
                      .order(@order)
                      .page(params[:page])
                      .per(40)
  end

  # GET /adverse_events/1
  def show
  end

  # GET /adverse_events/new
  def new
    @adverse_event = current_user.adverse_events
                     .where(project_id: @project.id)
                     .new
  end

  # GET /adverse_events/1/edit
  def edit
  end

  # POST /adverse_events
  def create
    @adverse_event = current_user.adverse_events
                     .where(project_id: @project.id)
                     .new(adverse_event_params)
    if @adverse_event.save
      redirect_to [@project, @adverse_event], notice: 'Adverse event was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /adverse_events/1
  def update
    if @adverse_event.update(adverse_event_params)
      redirect_to [@project, @adverse_event], notice: 'Adverse event was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /adverse_events/1
  def destroy
    @adverse_event.destroy
    redirect_to project_adverse_events_path(@project), notice: 'Adverse event was successfully destroyed.'
  end

  private

  def set_viewable_adverse_event
    @adverse_event = current_user.all_viewable_adverse_events.find_by_id params[:id]
  end

  def set_editable_adverse_event
    @adverse_event = current_user.all_adverse_events.find_by_id params[:id]
  end

  def redirect_without_adverse_event
    empty_response_or_root_path(project_adverse_events_path(@project)) unless @adverse_event
  end

  def adverse_event_params
    params.require(:adverse_event).permit(
      :description, :serious, :closed,
      # Attribute Accessor
      :subject_code, :event_date
    )
  end
end
