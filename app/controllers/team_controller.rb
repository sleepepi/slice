# frozen_string_literal: true

# Displays project team and team member pages.
class TeamController < ApplicationController
  before_action :authenticate_user!
  before_action :find_viewable_project_or_redirect, only: [:index, :show]
  before_action :find_editable_project_or_redirect, only: [:update, :destroy]
  before_action :find_user_or_redirect, only: [:show, :update, :destroy]

  layout "layouts/full_page_sidebar_dark"

  # GET /projects/:project_id/team
  def index
    # @users = @project.team_users
  end

  # # GET /projects/:project_id/team/:id
  # def show
  # end

  # POST /project/:project_id/team/:id
  def update
    case params[:role]
    when "project"
      @role = @project.project_users.find_by(id: params[:role_id], user: @user)
    when "site"
      @role = @project.site_users.find_by(id: params[:role_id], user: @user)
    when "admin"
      @role = @project.ae_review_admins.find_by(id: params[:role_id], user: @user)
    when "team"
      @role = @project.ae_team_members.find_by(id: params[:role_id], user: @user)
    end

    if @role&.destroy
      if @project.team_users.where(id: @user.id).present?
        redirect_to project_team_member_path(@project, @user), notice: "Role was successfully removed from #{@user.full_name}."
      else
        redirect_to project_team_path(@project), notice: "#{@user.full_name} was successfully removed from project."
      end
    else
      redirect_to project_team_path(@project), notice: "Role was not found for #{@user.full_name}."
    end
  end

  # DELETE /projects/:project_id/team/:id
  def destroy
    @user.remove_from_project!(@project)
    redirect_to project_team_path(@project), notice: "#{@user.full_name} was successfully removed from project."
  end

  private

  def find_user_or_redirect
    @user = @project.team_users.find_by(id: params[:id])
    empty_response_or_root_path(@project) unless @user
  end
end
