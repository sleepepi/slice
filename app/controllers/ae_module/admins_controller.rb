class AeModule::AdminsController < AeModule::BaseController
  before_action :find_review_admin_project_or_redirect
  before_action :find_adverse_event_or_redirect, except: [
    :inbox, :setup_designs, :submit_designs, :remove_designment
  ]
  before_action :set_sheet, only: [:form, :form_save]
  before_action :find_sheet_or_redirect, only: [:sheet]

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
      redirect_to ae_module_adverse_event_path(@project, @adverse_event), notice: "Request successfully submitted."
    else
      render :request_additional_details
    end
  end

  # POST /projects/:project_id/ae-module/admins/adverse-event/:id/info-requests/:info_request_id
  def resolve_info_request
    @info_request.resolve!(current_user)
    redirect_to ae_module_adverse_event_path(@project, @adverse_event), notice: "Info request was marked as resolved."
  end

  # DELETE /projects/:project_id/ae-module/admins/adverse-events/:id/info-requests/:info_request_id
  def destroy_info_request
    @adverse_event_info_request = @adverse_event.ae_adverse_event_info_requests.find_by(id: params[:info_request_id])
    @adverse_event_info_request.destroy
    redirect_to ae_module_adverse_event_path(@project, @adverse_event), notice: "Request successfully deleted."
  end


  # POST /projects/:project_id/ae-module/admins/adverse-events/:id/assign-team
  def assign_team
    team = @project.ae_review_teams.find_by_param(params[:review_team_id])
    if team
      @adverse_event.assign_team!(current_user, team)
      notice = "Team successfully assigned."
    else
      notice = "Unable to assign team."
    end
    redirect_to ae_module_adverse_event_path(@project, @adverse_event), notice: notice
  end

  # # GET /projects/:project_id/ae-module/admins/setup-designs
  # def setup_designs
  # end

  # POST /projects/:project_id/ae-module/admins/submit-designs
  def submit_designs
    # Pathway may be nil.
    @pathway = @project.ae_team_pathways.find_by(id: params[:pathway_id])

    ActiveRecord::Base.transaction do
      @project.ae_designments.where(ae_team_pathway: @pathway, role: params[:role]).destroy_all
      index = 0
      (params[:design_ids] || []).uniq.each do |design_id|
        design = @project.designs.find_by(id: design_id)
        next unless design

        @project.ae_designments.create(
          design: design,
          position: index,
          role: params[:role],
          ae_review_team: @pathway&.ae_review_team,
          ae_team_pathway: @pathway
        )
        index += 1
      end
    end
    @designments = @project.ae_designments.where(ae_team_pathway: @pathway, role: params[:role])
    render :designments
  end

  # DELETE /projects/:project_id/ae-module/admins/remove-designment
  def remove_designment
    designment = @project.ae_designments.find_by(id: params[:designment_id])
    designment.destroy
    @pathway = @project.ae_team_pathways.find_by(id: params[:pathway_id])
    @designments = @project.ae_designments.where(ae_team_pathway: @pathway, role: params[:role])
    render :designments
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

  def info_request_params
    params.require(:ae_adverse_event_info_request).permit(:comment)
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
      ae_adverse_event: @adverse_event
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
