class ProjectUsersController < ApplicationController
  before_action :authenticate_user!

  # POST /project_users/1.js
  def resend
    @project_user = ProjectUser.find_by_id(params[:id])
    @project = current_user.all_projects.find_by_id(@project_user.project_id) if @project_user

    if @project and @project_user
      @project_user.generate_invite_token!
      # resend.js.erb
    else
      render nothing: true
    end
  end

  def accept
    @project_user = ProjectUser.find_by_invite_token(params[:invite_token])
    if @project_user and @project_user.user == current_user
      redirect_to @project_user.project, notice: "You have already been added to #{@project_user.project.name}."
    elsif @project_user and @project_user.user
      redirect_to root_path, alert: "This invite has already been claimed."
    elsif @project_user
      @project_user.update_attributes user_id: current_user.id
      redirect_to @project_user.project, notice: "You have been successfully been added to the project."
    else
      redirect_to root_path, alert: 'Invalid invitation token.'
    end
  end

  # DELETE /project_users/1
  # DELETE /project_users/1.json
  def destroy
    @project_user = ProjectUser.find_by_id(params[:id])
    @project = current_user.all_projects.find_by_id(@project_user.project_id) if @project_user
    @project = current_user.all_viewable_projects.find_by_id(@project_user.project_id) if @project.blank? and @project_user and current_user == @project_user.user

    respond_to do |format|
      if @project and @project_user
        @project_user.destroy
        format.js { render 'projects/members' }
        format.json { head :no_content }
      else
        format.js { render nothing: true }
        format.json { head :no_content }
      end
    end
  end
end
