# frozen_string_literal: true

# Allows project editors to edit team site roles.
class SiteUsersController < ApplicationController
  before_action :authenticate_user!

  # PATCH /site_users/1
  # PATCH /site_users/1.js
  def update
    @project = current_user.all_projects.find_by_param(params[:project_id])
    @site_user = @project.site_users.find_by(id: params[:id]) if @project
    if @project && @project.editable_by?(current_user) && @project.blinding_enabled? && @project.unblinded?(current_user) && @site_user
      @site_user.update unblinded: (params[:unblinded] == "1")
      flash_notice = "Set member as #{"un" if @site_user.unblinded?}blinded."
    end
    respond_to do |format|
      format.html { redirect_to @project ? team_project_path(@project) : root_path, notice: flash_notice }
      format.js
    end
  end

  # DELETE /site_users/1
  def destroy
    @site_user = SiteUser.find_by(id: params[:id])
    @site = current_user.all_sites.find_by(id: @site_user.site_id) if @site_user
    @project = @site_user.project if @site_user
    respond_to do |format|
      if @site && @project
        @site_user.destroy
        format.html { redirect_to [@site.project, @site] }
        format.js { render "projects/members" }
      elsif @site_user.user == current_user && @project
        @site = @site_user.site
        @site_user.destroy
        format.html { redirect_to root_path }
        format.js { render "projects/members" }
      else
        format.html { redirect_to root_path }
        format.js { head :ok }
      end
    end
  end
end
