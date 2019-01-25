class AeModule::ReviewersController < AeModule::BaseController
  before_action :find_reviewer_project_or_redirect
  before_action :find_assignment_or_redirect, only: [
    :review, :review_save, :sheet
  ]
  before_action :set_sheet, only: [:review, :review_save]
  before_action :find_sheet_or_redirect, only: [:sheet]
  before_action :set_project_member
  layout :sidebar_layout

  # GET /projects/:project_id/ae-module/reviewers/inbox
  def inbox
    @assignments = assignments.order(created_at: :desc).page(params[:page]).per(20)
  end

  # # GET /projects/:project_id/ae-module/reviewers/adverse-events/:assignment_id/reviews/:design_id
  # def review
  # end

  # POST /projects/:project_id/ae-module/reviewers/adverse-events/:assignment_id/sheets
  def review_save
    update_type = (@sheet.new_record? ? "sheet_create" : "sheet_update")
    if SheetTransaction.save_sheet!(@sheet, sheet_params, variables_params, current_user, request.remote_ip, update_type)
      @project.ae_sheets.where(
        ae_adverse_event: @assignment.ae_adverse_event,
        sheet: @sheet,
        role: @assignment.principal? ? "principal_reviewer" : "reviewer",
        ae_team: @assignment.ae_team,
        ae_assignment: @assignment
      ).first_or_create
      proceed_to_next_design
    else
      render :review
    end
  end

  # # GET /projects/:project_id/ae-module/reviewers/adverse-events/:assignment_id/sheets/:sheet_id
  # def sheet
  # end

  private

  def assignments
    @project.ae_assignments.where(reviewer: current_user)
  end

  def find_reviewer_project_or_redirect
    @project = Project.current.where(
      id: AeTeamMember.where(user: current_user, reviewer: true).or(
        AeTeamMember.where(user: current_user, principal_reviewer: true)
      ).select(:project_id)
    ).find_by_param(params[:project_id])
    redirect_without_project
  end

  def find_assignment_or_redirect
    @assignment = assignments.find_by(id: params[:assignment_id])
    if @assignment
      @adverse_event = @assignment.ae_adverse_event
      set_roles
    end
    empty_response_or_root_path(ae_module_reviewers_inbox_path(@project)) unless @assignment
  end

  def find_sheet_or_redirect
    @sheet = @assignment.sheets.find_by(id: params[:sheet_id])
    empty_response_or_root_path(ae_module_reviewers_assignment_path(@project, @assignment)) unless @sheet
  end

  def set_sheet
    @subject = @assignment.ae_adverse_event.subject
    @design = @assignment.ae_team_pathway.designs.find_by_param(params[:design_id])
    if @design
      @sheet = @assignment.sheets.find_by(design: @design)
      @sheet = @assignment.sheets.where(
        project: @project,
        design: @design,
        subject: @subject,
        ae_adverse_event: @assignment.ae_adverse_event,
        user: current_user
      ).new(sheet_params) unless @sheet
    else
      empty_response_or_root_path(ae_module_adverse_event_path(@project, @adverse_event))
    end
  end

  def proceed_to_next_design
    design = @assignment.next_design(@design)
    if design
      redirect_to ae_module_reviewers_review_path(@project, @assignment, design)
    else
      @assignment.complete!
      redirect_to ae_module_adverse_event_path(@project, @assignment.ae_adverse_event)
    end
  end
end
