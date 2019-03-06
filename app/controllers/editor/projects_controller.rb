# frozen_string_literal: true

# Allows project editors to modify projects.
class Editor::ProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_editable_project_or_redirect

  layout "layouts/full_page_sidebar_dark"

  # # GET /editor/projects/1/settings
  # def settings
  # end

  # # GET /editor/projects/1/advanced
  # def advanced
  # end

  # # GET /editor/projects/1/edit
  # def edit
  # end

  # PATCH /editor/projects/1
  def update
    if @project.update(project_params)
      redirect_to settings_editor_project_path(@project), notice: "Project was successfully updated."
    else
      render :edit
    end
  end

  # PATCH /editor/projects/1/toggle.js
  def toggle
    @feature = params[:feature]
    if @feature.in?(%w(handoffs medications randomizations translations)) ||
       (@feature == "blinding" && @project.unblinded?(current_user))
      key = "#{@feature}_enabled"
      @project.update(key => (params[:enabled] == "1"))
    else
      head :ok
    end
  end

  # # GET /editor/projects/:project_id/setup-designs
  # def setup_designs
  # end

  # # GET /editor/projects/:project_id/setup-medications
  # def setup_medications
  # end

  # POST /editor/projects/:project_id/submit-designs
  def submit_designs
    @pathway = @project.ae_team_pathways.find_by(id: params[:pathway_id])
    @project.update_designments(@pathway, params[:role], params[:design_ids])
    @designments = @project.ae_designments.where(ae_team_pathway: @pathway, role: params[:role])
    render :designments
  end

  # DELETE /editor/projects/:project_id/remove-designment
  def remove_designment
    designment = @project.ae_designments.find_by(id: params[:designment_id])
    designment.destroy
    @pathway = @project.ae_team_pathways.find_by(id: params[:pathway_id])
    @designments = @project.ae_designments.where(ae_team_pathway: @pathway, role: params[:role])
    render :designments
  end

  # POST /editor/projects/:project_id/add-language
  def add_language
    @project.project_languages.where(language_code: params[:language_code]).first_or_create
    render "languages"
  end

  # DELETE /editor/projects/:project_id/remove-language
  def remove_language
    @project.project_languages.where(language_code: params[:language_code]).destroy_all
    render "languages"
  end

  private

  # Overwriting application_controller
  def find_editable_project_or_redirect
    super(:id)
  end

  def redirect_without_project
    super(projects_path)
  end

  def project_params
    params.require(:project).permit(
      :name, :slug, :description, :disable_all_emails,
      :hide_values_on_pdfs,
      :adverse_events_enabled,
      :auto_lock_sheets,
      # Uploaded Logo
      :logo, :logo_uploaded_at, :logo_cache, :remove_logo
    )
  end
end
