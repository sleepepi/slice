# frozen_string_literal: true

# Allows project members to invite others to collaborate on project.
# Others can accept invite tokens to be added to projects
class ProjectUsersController < ApplicationController
  before_action :authenticate_user!, except: [:invite]

  def invite
    session[:invite_token] = params[:invite_token]
    if current_user
      redirect_to accept_project_users_path
    else
      redirect_to new_user_session_path
    end
  end

  # POST /project_users/1.js
  def resend
    @project_user = ProjectUser.find_by_id(params[:id])
    @project = current_user.all_projects.find_by_id(@project_user.project_id) if @project_user

    if @project && @project_user
      @project_user.generate_invite_token!
      # resend.js.erb
    else
      render nothing: true
    end
  end

  def accept
    invite_token = session.delete(:invite_token)
    @project_user = ProjectUser.find_by_invite_token invite_token
    if @project_user && @project_user.user == current_user
      redirect_to @project_user.project, notice: "You have already been added to #{@project_user.project.name}."
    elsif @project_user && @project_user.user
      redirect_to root_path, alert: 'This invite has already been claimed.'
    elsif @project_user
      @project_user.update user_id: current_user.id
      redirect_to @project_user.project, notice: 'You have been successfully been added to the project.'
    else
      redirect_to root_path, alert: 'Invalid invitation token.'
    end
  end

  # DELETE /project_users/1
  def destroy
    @project_user = ProjectUser.find_by_id params[:id]
    @project = current_user.all_projects.find_by_id(@project_user.project_id) if @project_user
    if @project.blank? && @project_user && current_user == @project_user.user
      @project = current_user.all_viewable_projects.find_by_id(@project_user.project_id)
    end

    if @project && @project_user
      @project_user.destroy
      render 'projects/members'
    else
      render nothing: true
    end
  end
end
