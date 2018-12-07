class AeModule::ReportersController < AeModule::BaseController
  before_action :find_editable_project_or_editable_site_or_redirect
  before_action :redirect_blinded_users
  before_action :find_adverse_event_or_redirect, only: [
    :adverse_event, :adverse_event_files, :adverse_event_log,
    :resolve_info_request, :form, :form_save
  ]
  before_action :find_info_request_or_redirect, only: [:resolve_info_request]
  before_action :set_sheet, only: [:form, :form_save]

  # GET /projects/:project_id/ae-module/reporters/inbox
  def inbox
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
      redirect_to ae_module_reporters_adverse_event_path(@project, @adverse_event), notice: "Adverse event was successfully reported."
    else
      render :report
    end
  end

  # # GET /projects/:project_id/ae-module/reporters/adverse-event/:id
  # def adverse_event
  # end

  # # GET /projects/:project_id/ae-module/reporters/adverse-event/:id/log
  # def adverse_event_log
  # end

  # # GET /projects/:project_id/ae-module/reporters/adverse-event/:id/files
  # def adverse_event_files
  # end

  # POST /projects/:project_id/ae-module/reporters/adverse-event/:id/info-requests/:info_request_id
  def resolve_info_request
    @info_request.resolve!(current_user)
    redirect_to ae_module_reporters_adverse_event_path(@project, @adverse_event), notice: "Adverse event was successfully reported."
  end

  # GET /projects/:project_id/ae-module/reporters/adverse-events/:id/form/:design_id
  def form
  end

  # POST /projects/:project_id/ae-module/reporters/adverse-events/:id/form/:design_id
  def form_save
    update_type = (@sheet.new_record? ? "sheet_create" : "sheet_update")
    if SheetTransaction.save_sheet!(@sheet, sheet_params, variables_params, current_user, request.remote_ip, update_type)
      @project.ae_sheets.where(
        ae_adverse_event: @adverse_event,
        sheet: @sheet,
        role: "reporter"
      ).first_or_create
      proceed_to_next_design
    else
      render :form
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

  def find_adverse_event_or_redirect
    @adverse_event = @project.ae_adverse_events.where(user: current_user).find_by(id: params[:id])
    @subject = @adverse_event&.subject
    empty_response_or_root_path(ae_module_reporters_inbox_path(@project)) unless @adverse_event
  end

  def find_info_request_or_redirect
    @info_request = @adverse_event.ae_adverse_event_info_requests.find_by(id: params[:info_request_id])
    empty_response_or_root_path(ae_module_reporters_adverse_event_path(@project, @adverse_event)) unless @info_request
  end

  def set_sheet
    @designments = @project.ae_designments.where(role: "reporter")
    @design = @project.designs.where(id: @designments.select(:design_id)).find_by_param(params[:design_id])
    @ae_sheets = @adverse_event.ae_sheets.where(role: "reporter")
    @sheet = @adverse_event.sheets.where(id: @ae_sheets.select(:sheet_id)).find_by(design: @design)
    @sheet = @adverse_event.sheets.where(
      project: @project,
      design: @design,
      subject: @subject,
      ae_adverse_event: @adverse_event
    ).new(sheet_params) unless @sheet
  end

  def proceed_to_next_design
    design = @project.next_design("reporter", @design)
    if design
      redirect_to ae_module_reporters_form_path(@project, @adverse_event, design)
    else
      redirect_to ae_module_reporters_adverse_event_path(@project, @adverse_event)
    end
  end
end
