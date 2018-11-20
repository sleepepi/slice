class AeModule::ReviewersController < ApplicationController
  before_action :authenticate_user!
  before_action :find_reviewer_project_or_redirect
  before_action :find_assignment_or_redirect, only: [:assignment, :complete_assignment]

  def dashboard
  end

  # GET /projects/:project_id/ae-module/reviewers/inbox
  def inbox
    @assignments = assignments.order(id: :desc).page(params[:page]).per(20)
  end

  # # GET /projects/:project_id/ae-module/reviewers/adverse-events/:assignment_id
  # def assignment
  # end

  # POST /projects/:project_id/ae-module/reviewers/adverse-events/:assignment_id
  def complete_assignment
    @assignment.complete!
    redirect_to ae_module_reviewers_assignment_path(@project, @assignment), notice: "Assignment completed successfully."
  end

  private

  def assignments
    @project.ae_adverse_event_reviewer_assignments.where(reviewer: current_user)
  end

  def find_reviewer_project_or_redirect
    @project = Project.current.where(id: AeReviewTeamMember.where(user: current_user, reviewer: true).select(:project_id)).find_by_param(params[:project_id])
    @project = current_user.all_viewable_and_site_projects.find_by_param(params[:project_id]) unless @project # TODO: Remove
    redirect_without_project
  end

  def find_assignment_or_redirect
    @assignment = assignments.find_by(id: params[:assignment_id])
    empty_response_or_root_path(ae_module_reviewers_inbox_path(@project)) unless @assignment
  end
end
