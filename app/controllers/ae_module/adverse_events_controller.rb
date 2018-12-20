# frozen_string_literal: true

# Allows reporters and review admins to manage adverse events.
class AeModule::AdverseEventsController < AeModule::BaseController
  before_action :find_review_admin_project_or_reporter_project_or_redirect
  before_action :redirect_blinded_users
  before_action :find_adverse_event_or_redirect, only: [:show, :edit, :update, :log]

  # GET /projects/:project_id/ae-module/adverse-events
  def index
    @adverse_events = adverse_events.order(reported_at: :desc).page(params[:page]).per(20)
  end

  # # GET /projects/:project_id/ae-module/adverse-events/:id
  # def show
  # end

  # GET /projects/:project_id/ae-module/adverse-events/new
  def new
    @adverse_event = @project.ae_adverse_events.new
  end

  # POST /projects/:project_id/ae-module/adverse-events
  def create
    @adverse_event = @project.ae_adverse_events.where(user: current_user).new(ae_adverse_event_params)
    if @adverse_event.save
      @adverse_event.opened!(current_user)
      redirect_to ae_module_adverse_event_path(@project, @adverse_event), notice: "Adverse event was successfully opened."
    else
      render :new
    end
  end

  # # GET /projects/:project_id/ae-module/adverse-events/:id/edit
  # def edit
  # end

  def update
    if @adverse_event.update(ae_adverse_event_params)
      redirect_to ae_module_adverse_event_path(@project, @adverse_event), notice: "Adverse event was successfully updated."
    else
      render :edit
    end
  end

  private

  def ae_adverse_event_params
    params.require(:ae_adverse_event).permit(
      :description,
      # Attribute Accessor
      :subject_code
    )
  end

  def find_review_admin_project_or_reporter_project_or_redirect
    project = Project.current.find_by_param(params[:project_id])
    if project.ae_admin?(current_user)
      @project = project
    elsif project.ae_reporter?(current_user)
      @project = project
    else
      redirect_without_project
    end
  end

  def find_adverse_event_or_redirect
    super(:id)
  end
end
