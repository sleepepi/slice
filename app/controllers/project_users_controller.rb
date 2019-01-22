# frozen_string_literal: true

# Allows project editors to edit team roles.
class ProjectUsersController < ApplicationController
  before_action :authenticate_user!

  # PATCH /project_users/1
  # PATCH /project_users/1.js
  def update
    @project = current_user.all_projects.find_by(id: params[:project_id])
    @project_user = @project.project_users.find_by(id: params[:id]) if @project
    if @project && @project.editable_by?(current_user) && @project.blinding_enabled? && @project.unblinded?(current_user) && @project_user
      @project_user.update unblinded: (params[:unblinded] == "1")
      flash_notice = "Set member as #{"un" if @project_user.unblinded?}blinded."
    end
    respond_to do |format|
      format.html { redirect_to @project ? team_project_path(@project) : root_path, notice: flash_notice }
      format.js
    end
  end

  # DELETE /project_users/1
  def destroy
    @project_user = ProjectUser.find_by(id: params[:id])
    @project = current_user.all_projects.find_by(id: @project_user.project_id) if @project_user
    if @project.blank? && @project_user && current_user == @project_user.user
      @project = current_user.all_viewable_and_site_projects.find_by(id: @project_user.project_id)
    end
    if @project && @project_user
      @project_user.destroy
      render "projects/members"
    else
      head :ok
    end
  end
end
