# frozen_string_literal: true

# Allows project owners to transfer ownership and delete projects.
class Owner::ProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_owner_project_or_redirect

  layout "layouts/full_page_sidebar_dark"

  # # GET /projects/1/api
  # def api
  # end

  # POST /projects/1/api/generate-api-key
  def generate_api_key
    @project.reset_token!
    render :settings_api
  end

  # POST /projects/1/transfer
  def transfer
    new_owner = @project.users.find_by(id: params[:user_id])
    if new_owner
      @project.transfer_to_user(new_owner, current_user)
      flash[:notice] = "Project was successfully transferred to #{new_owner.full_name}."
    end
    redirect_to settings_editor_project_path(@project)
  end

  # DELETE /projects/1
  # DELETE /projects/1.js
  def destroy
    @project.destroy

    respond_to do |format|
      format.html { redirect_to root_path, notice: "Project was successfully deleted." }
      format.js
    end
  end

  private

  def find_owner_project_or_redirect
    @project = current_user.projects.find_by_param(params[:id])
    redirect_without_project
  end

  def redirect_without_project
    super(projects_path)
  end
end
