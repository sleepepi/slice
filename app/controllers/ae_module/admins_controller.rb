class AeModule::AdminsController < AeModule::BaseController
  before_action :find_review_admin_project_or_redirect
  before_action :find_adverse_event_or_redirect
  before_action :set_sheet, only: [:form, :form_save]
  before_action :find_sheet_or_redirect, only: [:sheet]

  # POST /projects/:project_id/ae-module/admins/adverse-events/:id/assign-team
  def assign_team
    team = @project.ae_teams.find_by_param(params[:team_id])
    if team
      @adverse_event.assign_team!(current_user, team)
      notice = "Team successfully assigned."
    else
      notice = "Unable to assign team."
    end
    redirect_to ae_module_adverse_event_path(@project, @adverse_event), notice: notice
  end

  # GET /projects/:project_id/ae-module/admins/adverse-events/:id/form/:design_id
  def form
  end

  # POST /projects/:project_id/ae-module/admins/adverse-events/:id/form/:design_id
  def form_save
    update_type = (@sheet.new_record? ? "sheet_create" : "sheet_update")
    if SheetTransaction.save_sheet!(@sheet, sheet_params, variables_params, current_user, request.remote_ip, update_type)
      @project.ae_sheets.where(
        ae_adverse_event: @adverse_event,
        sheet: @sheet,
        role: "admin"
      ).first_or_create
      proceed_to_next_design
    else
      render :form
    end
  end


  # POST /projects/:project_id/ae-module/admins/adverse-events/:id/close
  def close_adverse_event
    @adverse_event.close!(current_user)
    redirect_to ae_module_adverse_event_path(@project, @adverse_event), notice: "Adverse event successfully closed."
  end

  # POST /projects/:project_id/ae-module/admins/adverse-events/:id/reopen
  def reopen_adverse_event
    @adverse_event.reopen!(current_user)
    redirect_to ae_module_adverse_event_path(@project, @adverse_event), notice: "Adverse event successfully reopened."
  end

  private

  def find_review_admin_project_or_redirect
    @project = Project.current.where(id: AeReviewAdmin.where(user: current_user).select(:project_id)).find_by_param(params[:project_id])
    redirect_without_project
  end

  def find_adverse_event_or_redirect
    super(:id)
  end

  def find_sheet_or_redirect
    @sheet =  @adverse_event.sheets.find_by(id: params[:sheet_id])
    empty_response_or_root_path(ae_module_adverse_event_path(@project, @adverse_event)) unless @sheet
  end

  def set_sheet
    @designments = @project.ae_designments.where(role: "admin")
    @design = @project.designs.where(id: @designments.select(:design_id)).find_by_param(params[:design_id])
    @ae_sheets = @adverse_event.ae_sheets.where(role: "admin")
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
    design = @project.next_design("admin", @design)
    if design
      redirect_to ae_module_admins_form_path(@project, @adverse_event, design)
    else
      redirect_to ae_module_adverse_event_path(@project, @adverse_event)
    end
  end
end
