# frozen_string_literal: true

# Managers can view adverse events, make assignments, and finalize reviews.
class AeModule::ManagersController < AeModule::BaseController
  before_action :find_manager_project_or_redirect
  before_action :find_team_or_redirect, except: [:inbox]
  before_action :find_adverse_event_team, except: [:inbox]

  # GET /projects/:project_id/ae-module/managers/inbox
  def inbox
    @adverse_event_teams = adverse_event_teams.order(id: :desc).page(params[:page]).per(20)
  end

  # # GET /projects/:project_id/ae-module/managers/teams/:team_id/adverse-events/:id
  # def adverse_event
  # end

  # # GET /projects/:project_id/ae-module/managers/teams/:team_id/adverse-events/:id/assignments
  # def determine_pathway
  # end

  # POST  /projects/:project_id/ae-module/managers/teams/:team_id/adverse-events/:id/assign-reviewers
  def assign_reviewers
    pathway_ids = (params[:pathway_ids].presence || {}).keys
    reviewer_ids = (params[:reviewer_ids].presence || {}).keys
    @pathways = @team.ae_team_pathways.where(id: pathway_ids)
    @reviewers = @team.reviewers.where(id: reviewer_ids)
    @principal_reviewer = @team.principal_reviewers.find_by(id: params[:principal_reviewer_id])

    original_assignment_ids = @adverse_event.ae_assignments.where(ae_team: @team).pluck(:id)

    assignments = []

    @pathways.each do |pathway|
      if @principal_reviewer
        assignment = @adverse_event.current_and_deleted_assignments.where(
          project: @project,
          ae_team: @team,
          manager: current_user,
          reviewer: @principal_reviewer,
          ae_team_pathway: pathway,
          principal: true
        ).first_or_create
        assignment.update deleted: false
        assignments << assignment
      end

      @reviewers.each do |reviewer|
        assignment = @adverse_event.current_and_deleted_assignments.where(
          project: @project,
          ae_team: @team,
          manager: current_user,
          reviewer: reviewer,
          ae_team_pathway: pathway,
          principal: false
        ).first_or_create
        assignment.update deleted: false
        assignments << assignment
      end
    end

    added_assignments = @adverse_event.ae_assignments.where(ae_team: @team).where.not(id: original_assignment_ids)
    removed_assignments = @adverse_event.ae_assignments.where(ae_team: @team).where.not(id: assignments.collect(&:id)).destroy_all

    # TODO: Generate in app notifications, email, and LOG notificiations to AENotificationsLog for Info Request (to "reviewer")

    if removed_assignments.present?
      @adverse_event.ae_log_entries.create(
        project: @project,
        user: current_user,
        entry_type: "ae_reviewers_unassigned",
        ae_team: @team,
        assignments: removed_assignments
      )
    end

    if added_assignments.present?
      @adverse_event.ae_log_entries.create(
        project: @project,
        user: current_user,
        entry_type: "ae_reviewers_assigned",
        ae_team: @team,
        assignments: added_assignments
      )
    end

    if added_assignments.present?
      flash[:notice] = "Reviewers were successfully assigned."
    elsif removed_assignments.present?
      flash[:notice] = "Reviewers were successfully unassigned."
    else
      flash[:notice] = "No changes made."
    end
    redirect_to ae_module_adverse_event_path(@project, @adverse_event)
  end

  # POST /projects/:project_id/ae-module/managers/teams/:team_id/adverse-events/:id/team-review-completed
  def team_review_completed
    if @adverse_event_team.team_review_uncompleted?
      @adverse_event_team.update(team_review_completed_at: Time.zone.now)
      @adverse_event.ae_log_entries.create(
        project: @project,
        user: current_user,
        entry_type: "ae_team_review_completed",
        ae_team: @team
      )
      flash[:notice] = "Team review was successfully marked as completed."
    end
    redirect_to ae_module_adverse_event_path(@project, @adverse_event)
  end

  # POST /projects/:project_id/ae-module/managers/teams/:team_id/adverse-events/:id/team-review-uncompleted
  def team_review_uncompleted
    if @adverse_event_team.team_review_completed?
      @adverse_event_team.update(team_review_completed_at: nil)
      @adverse_event.ae_log_entries.create(
        project: @project,
        user: current_user,
        entry_type: "ae_team_review_uncompleted",
        ae_team: @team
      )
      flash[:notice] = "Team review was successfully reopened."
    end
    redirect_to ae_module_adverse_event_path(@project, @adverse_event)
  end

  private

  def adverse_event_teams
    @project.ae_adverse_event_teams
            .joins(:ae_adverse_event, ae_team: :ae_team_members).merge(
              AeTeamMember.where(manager: true, user: current_user)
            )
  end

  def find_manager_project_or_redirect
    @project = Project.current.where(id: AeTeamMember.where(user: current_user, manager: true).select(:project_id)).find_by_param(params[:project_id])
    redirect_without_project
  end

  def find_team_or_redirect
    @team = @project.ae_teams.find_by_param(params[:team_id])
    empty_response_or_root_path(ae_module_managers_inbox_path(@project)) unless @team
  end

  def find_adverse_event_team
    @adverse_event_team = adverse_event_teams.find_by(
      ae_adverse_event_id: params[:id],
      ae_team: @team
    )
    if @adverse_event_team
      @team = @adverse_event_team.ae_team
      @adverse_event = @adverse_event_team.ae_adverse_event
    else
      empty_response_or_root_path(ae_module_managers_inbox_path(@project))
    end
  end
end
