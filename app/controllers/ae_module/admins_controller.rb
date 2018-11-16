class AeModule::AdminsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_viewable_project_or_redirect
  before_action :find_adverse_event_or_redirect, only: [
    :adverse_event, :request_additional_details, :submit_request_additional_details
  ]

  def dashboard
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
      # @adverse_event_info_request.log_info # TODO: Generate notifications and log entries
      redirect_to ae_module_admins_adverse_event_path(@project, @adverse_event), notice: "Request submitted successfully."
    else
      render :request_additional_details
    end
  end

  private

  def find_adverse_event_or_redirect
    @adverse_event = @project.ae_adverse_events.find_by(id: params[:id])
    empty_response_or_root_path(ae_module_dashboard(@project)) unless @adverse_event
  end

  def info_request_params
    params.require(:ae_adverse_event_info_request).permit(
      :comment
    )
  end
end
