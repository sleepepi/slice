class AeModule::ReportersController < AeModule::BaseController
  before_action :find_editable_project_or_editable_site_or_redirect
  before_action :redirect_blinded_users
  before_action :find_adverse_event_or_redirect, only: [
    :form, :form_save, :send_for_review
  ]
  before_action :find_info_request_or_redirect, only: [:resolve_info_request]
  before_action :set_sheet, only: [:form, :form_save]

  # GET /projects/:project_id/ae-module/reporters/adverse-events/:id/form/:design_id
  def form
  end

  # POST /projects/:project_id/ae-module/reporters/adverse-events/:id/form/:design_id
  def form_save
    update_type = (@sheet.new_record? ? "sheet_create" : "sheet_update")
    if SheetTransaction.save_sheet!(@sheet, sheet_params, variables_params, current_user, request.remote_ip, update_type)
      @ae_sheet = @project.ae_sheets.where(
        ae_adverse_event: @adverse_event,
        sheet: @sheet,
        role: "reporter"
      ).first_or_create
      @ae_sheet.sheet_saved!(current_user, update_type)
      proceed_to_next_design
    else
      render :form
    end
  end

  # POST /projects/:project_id/ae-module/reporters/adverse-events/:id/send-for-review
  def send_for_review
    if @adverse_event.ae_info_requests.where(ae_team_id: nil, resolved_at: nil).present?
      redirect_to ae_module_adverse_event_path(@project, @adverse_event), notice: "All information requests must be resolved before sending for review."
    else
      @adverse_event.sent_for_review!(current_user)
      redirect_to ae_module_adverse_event_path(@project, @adverse_event), notice: "Adverse event was successfully sent for review."
    end
  end

  private

  def adverse_events
    current_user.all_ae_adverse_events.where(project: @project)
  end

  def ae_adverse_event_params
    params.require(:ae_adverse_event).permit(
      :description,
      # Attribute Accessor
      :subject_code
    )
  end

  def find_adverse_event_or_redirect
    super(:id)
  end

  def find_info_request_or_redirect
    @info_request = @adverse_event.ae_info_requests.find_by(id: params[:info_request_id])
    empty_response_or_root_path(ae_module_adverse_event_path(@project, @adverse_event)) unless @info_request
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
      ae_adverse_event: @adverse_event,
      user: current_user
    ).new(sheet_params) unless @sheet
  end

  def proceed_to_next_design
    design = @project.next_design("reporter", @design)
    if design
      redirect_to ae_module_reporters_form_path(@project, @adverse_event, design)
    else
      redirect_to ae_module_adverse_event_path(@project, @adverse_event)
    end
  end
end
