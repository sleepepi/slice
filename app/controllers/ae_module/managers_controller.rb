# frozen_string_literal: true

# Managers can view adverse events, make assignments, and finalize reviews.
class AeModule::ManagersController < ApplicationController
  before_action :authenticate_user!
  before_action :find_manager_project_or_redirect
  before_action :find_review_team_or_redirect, except: [:dashboard, :inbox]
  before_action :find_adverse_event_review_team, except: [:dashboard, :inbox]

  # # GET /projects/:project_id/ae-module/managers/dashboard
  # def dashboard
  # end

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
      @adverse_event_review_team.assign_pathway!(current_user, pathway)
      redirect_to ae_module_managers_pathway_assignments_path(@project, @team, @adverse_event)
    else
      redirect_to ae_module_managers_determine_pathway_path(@project, @team, @adverse_event)
    end
  end

  # GET /projects/:project_id/ae-module/managers/teams/:team_id/adverse-events/:id/assignments/:pathway_id
  def pathway_assignments
    @pathway = @team.ae_team_pathways.find_by(id: params[:pathway_id])
    @assignments = @adverse_event.ae_adverse_event_reviewer_assignments.where(ae_review_team: @team, ae_team_pathway: @pathway).includes(:reviewer).to_a
  end

  # # GET /projects/:project_id/ae-module/managers/teams/:team_id/adverse-events/:id/final-review
  # def final_review
  # end

  # # GET /projects/:project_id/ae-module/managers/teams/:team_id/adverse-events/:id/final-review/submitted
  # def final_review_submitted
  # end

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

  def find_review_team_or_redirect
    @review_team = @project.ae_review_teams.find_by_param(params[:team_id])
    empty_response_or_root_path(ae_module_managers_inbox_path(@project)) unless @review_team
  end

  def find_adverse_event_review_team
    @adverse_event_review_team = adverse_event_review_teams.find_by(
      ae_adverse_event_id: params[:id],
      ae_review_team: @review_team # lookup is by param, "slug" or "id"
    )
    if @adverse_event_review_team
      @team = @adverse_event_review_team.ae_review_team
      @adverse_event = @adverse_event_review_team.ae_adverse_event
    else
      empty_response_or_root_path(ae_module_managers_inbox_path(@project))
    end
  end
end
