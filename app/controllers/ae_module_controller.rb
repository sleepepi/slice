class AeModuleController < ApplicationController
  before_action :authenticate_user!
  before_action :find_review_admin_project_or_redirect

  def dashboard
  end

  private

  def find_review_admin_project_or_redirect
    @project = Project.current.where(id: AeReviewAdmin.where(user: current_user).select(:project_id)).find_by_param(params[:project_id])
    @project = current_user.all_viewable_and_site_projects.find_by_param(params[:project_id]) unless @project # TODO: Remove
    redirect_without_project
  end
end
