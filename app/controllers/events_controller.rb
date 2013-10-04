class EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_editable_project, only: [ :index, :show, :new, :edit, :create, :update, :destroy ]
  before_action :redirect_without_project, only: [ :index, :show, :new, :edit, :create, :update, :destroy ]
  before_action :set_editable_event, only: [ :show, :edit, :update, :destroy ]
  before_action :redirect_without_event, only: [ :show, :edit, :update, :destroy ]

  # GET /events
  # GET /events.json
  def index
    @order = scrub_order(Event, params[:order], "events.name")
    @events = @project.events.search(params[:search]).order(@order).page(params[:page]).per( 20 )
  end

  # GET /events/1
  # GET /events/1.json
  def show
  end

  # GET /events/new
  def new
    @event = @project.events.new
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events
  # POST /events.json
  def create
    @event = @project.events.new(event_params)

    respond_to do |format|
      if @event.save
        format.html { redirect_to [@project, @event], notice: 'Event was successfully created.' }
        format.json { render action: 'show', status: :created, location: @event }
      else
        format.html { render action: 'new' }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /events/1
  # PUT /events/1.json
  def update
    respond_to do |format|
      if @event.update(event_params)
        format.html { redirect_to [@project, @event], notice: 'Event was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event.destroy

    respond_to do |format|
      format.html { redirect_to project_events_path(@project) }
      format.json { head :no_content }
    end
  end

  private

    def set_editable_event
      @event = @project.events.find_by_id(params[:id])
    end

    def redirect_without_event
      empty_response_or_root_path(project_events_path(@project)) unless @event
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def event_params
      params[:event] ||= {}

      params[:event][:user_id] = current_user.id

      params.require(:event).permit(:name, :description, :user_id)
    end

end
