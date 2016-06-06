# frozen_string_literal: true

# Allows project editors to modify projects.
class Editor::ProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_editable_project_or_redirect

  # GET /editor/projects/1/settings
  def settings
  end

  # POST /editor/projects/1/invite_user.js
  def invite_user
    create_member_invite
    render 'projects/members'
  end

  # GET /editor/projects/1/edit
  def edit
  end

  # PATCH /editor/projects/1
  def update
    if @project.update(project_params)
      redirect_to settings_editor_project_path(@project), notice: 'Project was successfully updated.'
    else
      render :edit
    end
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
      :name, :slug, :description, :subject_code_name,
      :show_documents, :disable_all_emails,
      :collect_email_on_surveys, :hide_values_on_pdfs,
      :randomizations_enabled, :adverse_events_enabled, :blinding_enabled,
      :handoffs_enabled, :auto_lock_sheets,
      # Uploaded Logo
      :logo, :logo_uploaded_at, :logo_cache, :remove_logo,
      # Will automatically generate a site if the project has no site
      :site_name
    )
  end

  def unblinded?
    if @project.unblinded?(current_user)
      (params[:unblinded] == '1')
    else
      false
    end
  end

  def editor?
    (params[:editor] == '1')
  end

  def member_scope
    site = @project.sites.find_by_id(params[:site_id])
    if site
      site.site_users.where(project_id: @project)
    else
      @project.project_users
    end
  end

  def invite_email
    params[:invite_email].to_s.strip
  end

  def associated_user
    current_user.associated_users.find_by_email(invite_email.split('[').last.to_s.split(']').first)
  end

  def create_member_invite
    if associated_user
      add_existing_member(associated_user)
    elsif invite_email.present?
      invite_new_member
    end
  end

  def add_existing_member(user)
    @member = member_scope.where(user_id: user.id).first_or_create(creator_id: current_user.id)
    @member.update editor: editor?, unblinded: unblinded?
  end

  def invite_new_member
    @member = member_scope.where(invite_email: invite_email).first_or_create(creator_id: current_user.id)
    @member.update editor: editor?, unblinded: unblinded?
    @member.generate_invite_token!
  end
end
