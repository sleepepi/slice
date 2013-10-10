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

  # POST /project_users
  # POST /project_users.json
  def create
    @project = current_user.all_projects.find_by_id(params[:project_user][:project_id])
    invite_email = (params[:editors_text] || params[:viewers_text]).to_s.strip
    user_email = invite_email.split('[').last.to_s.split(']').first
    @user = current_user.associated_users.find_by_email(user_email)

    respond_to do |format|
      if @project and (not @user.blank? or not invite_email.blank?)
        if @user
          @project_user = @project.project_users.where(user_id: @user.id).first_or_create( creator_id: current_user.id )
          @project_user.update( editor: (params[:project_user][:editor] == 'true') )
        elsif not invite_email.blank?
          @project_user = @project.project_users.where(invite_email: invite_email).first_or_create( creator_id: current_user.id )
          @project_user.update( editor: (params[:project_user][:editor] == 'true') )
          @project_user.generate_invite_token!
        end
        format.js { render 'index' }
        format.json { render json: @project_user, status: :created, location: @project_user }
      else
        format.js { render nothing: true }
        format.json { head :no_content }
      end
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
        format.js { render 'index' }
        format.json { head :no_content }
      else
        format.js { render nothing: true }
        format.json { head :no_content }
      end
    end
  end
end
