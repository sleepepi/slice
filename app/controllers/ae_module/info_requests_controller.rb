# frozen_string_literal: true

# Allows creation and resolution of information requests.
class AeModule::InfoRequestsController < AeModule::BaseController
  before_action :find_review_admin_or_review_team_or_reporter_project_or_redirect
  before_action :redirect_blinded_users
  before_action :find_adverse_event_or_redirect
  before_action :find_info_request_or_redirect, only: [
    :show, :destroy, :resolve
  ]

  # GET /projects/:project_id/ae-module/adverse-events/:adverse_event_id/info-requests/new
  def new
    @info_request = @adverse_event.ae_info_requests.new
  end

  # POST /projects/:project_id/ae-module/adverse-events/:adverse_event_id/info-requests
  def create
    @info_request = @adverse_event.ae_info_requests.where(project: @project, user: current_user).new(info_request_params)
    if @info_request.save
      @info_request.open!(current_user)
      redirect_to ae_module_adverse_event_path(@project, @adverse_event), notice: "Info request successfully submitted."
    else
      render :new
    end
  end

  # POST /projects/:project_id/ae-module/adverse-event/:adverse_event_id/info-requests/:id/resolve
  def resolve
    @info_request.resolve!(current_user)
    redirect_to ae_module_adverse_event_path(@project, @adverse_event), notice: "Info request marked as resolved."
  end

  # DELETE /projects/:project_id/ae-module/adverse-events/:adverse_event_id/info-requests/:id
  def destroy
    @info_request = @adverse_event.ae_info_requests.find_by(id: params[:id])
    @info_request.destroy
    redirect_to ae_module_adverse_event_path(@project, @adverse_event), notice: "Info request successfully deleted."
  end

  private

  def find_review_admin_or_review_team_or_reporter_project_or_redirect
    project = Project.current.find_by_param(params[:project_id])
    if project.ae_admin?(current_user)
      @project = project
    elsif project.ae_reporter?(current_user)
      @project = project
    elsif project.ae_team?(current_user)
      @project = project
    else
      redirect_without_project
    end
  end

  def info_requests
    if @project.ae_admin?(current_user)
      @adverse_event.ae_info_requests
    elsif @project.ae_reporter?(current_user)
      @adverse_event.ae_info_requests.where(ae_review_team_id: nil)
    else
      AeInfoRequest.none
    end
  end

  def info_request_params
    params.require(:ae_info_request).permit(:comment)
  end

  def find_info_request_or_redirect
    @info_request = info_requests.find_by(id: params[:id])
    empty_response_or_root_path(ae_module_adverse_event_path(@project, @adverse_event)) unless @info_request
  end
end
