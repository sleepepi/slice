class AeModule::AdminsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_review_admin_project_or_redirect
  before_action :find_adverse_event_or_redirect, only: [
    :adverse_event, :request_additional_details,
    :submit_request_additional_details, :assign_team
  ]

  def dashboard
  end

  # GET /projects/:project_id/ae-module/admins/inbox
  def inbox
    @adverse_events = @project.ae_adverse_events.order(reported_at: :desc).page(params[:page]).per(20)
  end

  # # GET /projects/:project_id/ae-module/admins/adverse-events/:id
  # def adverse_event
  # end

  # GET /projects/:project_id/ae-module/admins/adverse-events/:id/request-additional-details
  def request_additional_details
    @adverse_event_info_request = @adverse_event.ae_adverse_event_info_requests.new
  end

  # POST /projects/:project_id/ae-module/admins/adverse-events/:id/request-additional-details
  def submit_request_additional_details
    @adverse_event_info_request = @adverse_event.ae_adverse_event_info_requests.where(project: @project, user: current_user).new(info_request_params)
    if @adverse_event_info_request.save
      @adverse_event_info_request.open!(current_user)
      redirect_to ae_module_admins_adverse_event_path(@project, @adverse_event), notice: "Request submitted successfully."
    else
      render :request_additional_details
    end
  end

  # POST /projects/:project_id/ae-module/admins/adverse-events/:id/assign-team
  def assign_team
    team = @project.ae_review_teams.find_by_param(params[:review_team_id])
    if team
      @adverse_event.assign_team!(current_user, team)
      notice = "Team assigned successfully."
    else
      notice = "Unable to assign team."
    end
    redirect_to ae_module_admins_adverse_event_path(@project, @adverse_event), notice: notice
  end

  private

  def find_review_admin_project_or_redirect
    @project = Project.current.where(id: AeReviewAdmin.where(user: current_user).select(:project_id)).find_by_param(params[:project_id])
    @project = current_user.all_viewable_and_site_projects.find_by_param(params[:project_id]) unless @project # TODO: Remove
    redirect_without_project
  end

  def find_adverse_event_or_redirect
    @adverse_event = @project.ae_adverse_events.find_by(id: params[:id])
    empty_response_or_root_path(ae_module_dashboard_path(@project)) unless @adverse_event
  end

  def info_request_params
    params.require(:ae_adverse_event_info_request).permit(
      :comment
    )
  end
end
