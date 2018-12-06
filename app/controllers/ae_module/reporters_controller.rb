class AeModule::ReportersController < AeModule::BaseController
  before_action :find_editable_project_or_editable_site_or_redirect
  before_action :redirect_blinded_users
  before_action :find_adverse_event_or_redirect, only: [
    :adverse_event, :adverse_event_steps, :adverse_event_files,
    :resolve_info_request
  ]
  before_action :find_info_request_or_redirect, only: [:resolve_info_request]

  # GET /projects/:project_id/ae-module/reporters/overview
  def overview
    scope = @project.ae_adverse_events.where(user: current_user)
    @adverse_events = scope.order(reported_at: :desc).page(params[:page]).per(20)
  end

  # GET /projects/:project_id/ae-module/reporters/report
  def report
    @adverse_event = @project.ae_adverse_events.new
  end

  # POST /projects/:project_id/ae-module/reporters/report
  def submit_report
    @adverse_event = @project.ae_adverse_events.where(user: current_user).new(ae_adverse_event_params)
    if @adverse_event.save
      @adverse_event.opened!(current_user)
      redirect_to ae_module_reporters_overview_path(@project), notice: "Adverse event was successfully reported."
    else
      render :report
    end
  end

  # # GET /projects/:project_id/ae-module/reporters/adverse-event/:id
  # def adverse_event
  # end

  # # GET /projects/:project_id/ae-module/reporters/adverse-event/:id/steps
  # def adverse_event_steps
  # end

  # # GET /projects/:project_id/ae-module/reporters/adverse-event/:id/files
  # def adverse_event_files
  # end

  # POST /projects/:project_id/ae-module/reporters/adverse-event/:id/info-requests/:info_request_id
  def resolve_info_request
    @info_request.resolve!(current_user)
    redirect_to ae_module_reporters_adverse_event_path(@project, @adverse_event), notice: "Adverse event was successfully reported."
  end

  private

  def ae_adverse_event_params
    params.require(:ae_adverse_event).permit(
      :description,
      # Attribute Accessor
      :subject_code
    )
  end

  def find_adverse_event_or_redirect
    @adverse_event = @project.ae_adverse_events.where(user: current_user).find_by(id: params[:id])
    @subject = @adverse_event&.subject
    empty_response_or_root_path(ae_module_reporters_overview_path(@project)) unless @adverse_event
  end

  def find_info_request_or_redirect
    @info_request = @adverse_event.ae_adverse_event_info_requests.find_by(id: params[:info_request_id])
    empty_response_or_root_path(ae_module_reporters_adverse_event_path(@project, @adverse_event)) unless @info_request
  end
end
