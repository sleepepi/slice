class ProjectUsersController < ApplicationController
  before_filter :authenticate_user!

  # POST /project_users
  # POST /project_users.json
  def create
    @project = current_user.all_projects.find_by_id(params[:project_user][:project_id])
    user_email = (params[:librarians_text] || params[:members_text]).to_s.split('<').last.to_s.split('>').first
    @user = User.current.find_by_email(user_email)

    respond_to do |format|
      if @project and @user and @project_user = @project.project_users.find_or_create_by_user_id(@user.id)
        @project_user.update_attributes librarian: (params[:project_user][:librarian] == 'true')
        format.js { render 'index' }
        format.json { render json: @project_user, status: :created, location: @project_user }
      else
        format.js { render nothing: true }
        format.json { head :no_content }
      end
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
