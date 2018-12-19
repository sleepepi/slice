# frozen_string_literal: true

# Managers can view adverse events, make assignments, and finalize reviews.
class AeModule::ManagersController < AeModule::BaseController
  before_action :find_manager_project_or_redirect
  before_action :find_team_or_redirect, except: [:inbox]
  before_action :find_adverse_event_review_team, except: [:inbox]
  before_action :find_review_group_or_redirect, only: [
    :review_group, :review, :review_save, :sheet
  ]
  before_action :set_sheet, only: [:review, :review_save]
  before_action :find_sheet_or_redirect, only: [:sheet]

  # GET /projects/:project_id/ae-module/managers/inbox
  def inbox
    @adverse_event_review_teams = adverse_event_review_teams.order(id: :desc).page(params[:page]).per(20)
  end

  # # GET /projects/:project_id/ae-module/managers/teams/:team_id/adverse-events/:id
  # def adverse_event
  # end

  # # GET /projects/:project_id/ae-module/managers/teams/:team_id/adverse-events/:id/assignments
  # def determine_pathway
  # end

  # Same URL as above
  # POST  /projects/:project_id/ae-module/managers/teams/:team_id/adverse-events/:id/assignments
  def assign_pathway
    pathway = @team.ae_team_pathways.find_by(id: params[:pathway_id])
    if pathway
      @review_group = @team.assign_pathway!(current_user, @adverse_event, pathway)
      redirect_to ae_module_managers_review_group_path(@project, @team, @adverse_event, @review_group)
    else
      redirect_to ae_module_managers_determine_pathway_path(@project, @team, @adverse_event)
    end
  end

  # GET /projects/:project_id/ae-module/managers/teams/:team_id/adverse-events/:id/review-group/:review_group_id
  def review_group
    @assignments = @review_group.ae_adverse_event_reviewer_assignments.includes(:reviewer).to_a
  end

  # # GET /projects/:project_id/ae-module/managers/teams/:team_id/adverse-events/:id/final-review
  # def final_review
  # end

  # # GET /projects/:project_id/ae-module/managers/teams/:team_id/adverse-events/:id/final-review/submitted
  # def final_review_submitted
  # end


  # # GET /projects/:project_id/ae-module/managers/teams/:team_id/adverse-events/:id/review-group/:review_group_id/reviews/:design_id
  # def review
  # end

  # POST /projects/:project_id/ae-module/managers/teams/:team_id/adverse-events/:id/review-group/:review_group_id/reviews/:design_id
  def review_save
    update_type = (@sheet.new_record? ? "sheet_create" : "sheet_update")
    if SheetTransaction.save_sheet!(@sheet, sheet_params, variables_params, current_user, request.remote_ip, update_type)
      @project.ae_sheets.where(
        ae_adverse_event: @adverse_event,
        sheet: @sheet,
        role: "manager",
        ae_review_team: @team,
        ae_review_group: @review_group
      ).first_or_create
      proceed_to_next_design
    else
      render :review
    end
  end

  # GET /projects/:project_id/ae-module/managers/teams/:team_id/adverse-events/:id/review-group/:review_group_id/sheets/:sheet_id
  def sheet
  end


  private

  def adverse_event_review_teams
    @project.ae_adverse_event_review_teams
            .joins(:ae_adverse_event, ae_review_team: :ae_review_team_members).merge(
              AeReviewTeamMember.where(manager: true, user: current_user)
            )
  end

  def find_manager_project_or_redirect
    @project = Project.current.where(id: AeReviewTeamMember.where(user: current_user, manager: true).select(:project_id)).find_by_param(params[:project_id])
    @project = current_user.all_viewable_and_site_projects.find_by_param(params[:project_id]) unless @project # TODO: Remove
    redirect_without_project
  end

  def find_team_or_redirect
    @team = @project.ae_review_teams.find_by_param(params[:team_id])
    empty_response_or_root_path(ae_module_managers_inbox_path(@project)) unless @team
  end

  def find_adverse_event_review_team
    @adverse_event_review_team = adverse_event_review_teams.find_by(
      ae_adverse_event_id: params[:id],
      ae_review_team: @team
    )
    if @adverse_event_review_team
      @team = @adverse_event_review_team.ae_review_team
      @adverse_event = @adverse_event_review_team.ae_adverse_event
    else
      empty_response_or_root_path(ae_module_managers_inbox_path(@project))
    end
  end

  def find_review_group_or_redirect
    @review_group = @team.ae_review_groups.where(ae_adverse_event: @adverse_event).find_by(id: params[:review_group_id])
    empty_response_or_root_path(ae_module_managers_adverse_event_path(@project, @team, @adverse_event)) unless @review_group
  end

  def set_sheet
    @subject = @adverse_event.subject
    @design = @review_group.ae_team_pathway.designs.find_by_param(params[:design_id])
    @sheet = @review_group.sheets.find_by(design: @design)

    @sheet = @review_group.sheets.where(
      project: @project,
      design: @design,
      subject: @subject,
      ae_adverse_event: @adverse_event
    ).new(sheet_params) unless @sheet
  end

  def proceed_to_next_design
    design = @review_group.next_design(@design)
    if design
      redirect_to ae_module_managers_review_path(@project, @team, @review_group, design)
    else
      @review_group.complete!(current_user)
      redirect_to ae_module_managers_review_group_path(@project, @team, @review_group)
    end
  end

  def find_sheet_or_redirect
    @sheet =  @review_group.sheets.find_by(id: params[:sheet_id])
    empty_response_or_root_path(ae_module_managers_review_group_path(@project, @team, @adverse_event, @review_group)) unless @sheet
  end
end
