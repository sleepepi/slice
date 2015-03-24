class SchedulesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_editable_project, only: [ :index, :show, :new, :edit, :create, :update, :destroy, :add_event, :add_design ]
  before_action :redirect_without_project, only: [ :index, :show, :new, :edit, :create, :update, :destroy, :add_event, :add_design ]
  before_action :set_schedule, only: [ :show, :edit, :update, :destroy ]
  before_action :redirect_without_schedule, only: [ :show, :edit, :update, :destroy ]

  # POST /schedules/add_event.js
  def add_event
  end

  # POST /schedules/add_design.js
  def add_design
    @position = params[:position]
  end

  # GET /schedules
  # GET /schedules.json
  def index
    @order = scrub_order(Schedule, params[:order], "schedules.position")
    @schedules = @project.schedules.search(params[:search]).order(@order).page(params[:page]).per( 20 )
  end

  # GET /schedules/1
  # GET /schedules/1.json
  def show
  end

  # GET /schedules/new
  def new
    @schedule = @project.schedules.new(position: (@project.schedules.count + 1) * 10)
  end

  # GET /schedules/1/edit
  def edit
  end

  # POST /schedules
  # POST /schedules.json
  def create
    @schedule = @project.schedules.new(schedule_params)

    respond_to do |format|
      if @schedule.save
        format.html { redirect_to [@project, @schedule], notice: 'Schedule was successfully created.' }
        format.json { render action: 'show', status: :created, location: @schedule }
      else
        format.html { render action: 'new' }
        format.json { render json: @schedule.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /schedules/1
  # PUT /schedules/1.json
  def update
    respond_to do |format|
      if @schedule.update(schedule_params)
        format.html { redirect_to [@project, @schedule], notice: 'Schedule was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @schedule.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /schedules/1
  # DELETE /schedules/1.json
  def destroy
    @schedule.destroy

    respond_to do |format|
      format.html { redirect_to project_schedules_path(@project) }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_schedule
      @schedule = @project.schedules.find_by_id(params[:id])
    end

    def redirect_without_schedule
      empty_response_or_root_path(project_schedules_path(@project)) unless @schedule
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def schedule_params
      params[:schedule] ||= {}

      params[:schedule][:user_id] = current_user.id

      params.require(:schedule).permit(
        :name, :description, :items, :user_id, :position,
        { :items => [ :event_id, :interval, :units, :design_ids => [] ] }
      )
    end

end
