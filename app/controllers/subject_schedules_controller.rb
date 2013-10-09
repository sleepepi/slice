class SubjectSchedulesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_viewable_project, only: [ :show ]
  before_action :set_editable_project, only: [ :new, :create, :edit, :update, :destroy ]
  before_action :redirect_without_project, only: [ :show, :new, :create, :edit, :update, :destroy ]
  before_action :set_viewable_subject, only: [ :show ]
  before_action :set_editable_subject, only: [ :new, :create, :edit, :update, :destroy ]
  before_action :redirect_without_subject, only: [ :show, :new, :create, :edit, :update, :destroy ]
  before_action :set_subject_schedule, only: [ :show, :edit, :update, :destroy ]
  before_action :redirect_without_subject_schedule, only: [ :show, :edit, :update, :destroy ]


  # # GET /subject_schedules
  # # GET /subject_schedules.json
  # def index
  #   @subject_schedules = SubjectSchedule.all
  # end

  # # GET /subject_schedules/1
  # # GET /subject_schedules/1.json
  # def show
  # end

  # GET /subject_schedules/new
  def new
    @subject_schedule = @subject.subject_schedules.new
  end

  # GET /subject_schedules/1/edit
  def edit
  end

  # POST /subject_schedules
  # POST /subject_schedules.json
  def create
    @subject_schedule = @subject.subject_schedules.new(subject_schedule_params)

    respond_to do |format|
      if @subject_schedule.save
        format.html { redirect_to [@subject_schedule.subject.project, @subject_schedule.subject], notice: 'Subject schedule was successfully created.' }
        format.json { render action: 'show', status: :created, location: @subject_schedule }
        format.js   { render 'show' }
      else
        format.html { render action: 'new' }
        format.json { render json: @subject_schedule.errors, status: :unprocessable_entity }
        format.js   { render 'new' }
      end
    end
  end

  # PATCH/PUT /subject_schedules/1
  # PATCH/PUT /subject_schedules/1.json
  def update
    respond_to do |format|
      if @subject_schedule.update(subject_schedule_params)
        format.html { redirect_to [@subject_schedule.subject.project, @subject_schedule.subject], notice: 'Subject schedule was successfully updated.' }
        format.json { head :no_content }
        format.js   { render 'show' }
      else
        format.html { render action: 'edit' }
        format.json { render json: @subject_schedule.errors, status: :unprocessable_entity }
        format.js   { render 'edit' }
      end
    end
  end

  # DELETE /subject_schedules/1
  # DELETE /subject_schedules/1.json
  def destroy
    @subject_schedule.destroy
    respond_to do |format|
      format.html { redirect_to [@subject_schedule.subject.project, @subject_schedule.subject] }
      format.json { head :no_content }
      format.js { render 'show' }
    end
  end

  private

    def set_viewable_subject
      @subject = current_user.all_viewable_subjects.find_by_id(params[:subject_id])
    end

    def set_editable_subject
      @subject = @project.subjects.find_by_id(params[:subject_id])
    end

    def redirect_without_subject
      empty_response_or_root_path(project_subjects_path(@project)) unless @subject
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_subject_schedule
      @subject_schedule = @subject.subject_schedules.find_by_id(params[:id])
    end

    def redirect_without_subject_schedule
      empty_response_or_root_path(project_subject_path(@subject.project, @subject)) unless @subject_schedule
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def subject_schedule_params
      params[:subject_schedule] ||= { blank: '1' }

      params[:subject_schedule][:initial_due_date] = parse_date(params[:subject_schedule][:initial_due_date]) unless params[:subject_schedule][:initial_due_date].blank?

      params.require(:subject_schedule).permit(:schedule_id, :initial_due_date)
    end
end
