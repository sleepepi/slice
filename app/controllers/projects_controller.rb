# frozen_string_literal: true

# Allows projects to be viewed an edited.
class ProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_viewable_project_or_redirect, only: [
    :settings, :show, :collect, :share, :favorite, :activity, :logo,
    :archive, :restore
  ]

  # POST /projects/save_project_order.js
  def save_project_order
    page = [params[:page].to_i, 1].max
    params[:project_ids].each_with_index do |project_id, index|
      project_preference = current_user.project_preferences.where(project_id: project_id).first_or_create
      project_preference.update position: ((page - 1) * Project::PER_PAGE) + index
    end
    head :ok
  end

  # GET /projects/1/logo
  def logo
    send_file File.join(CarrierWave::Uploader::Base.root, @project.logo.url)
  end

  # POST /projects/1/favorite
  def favorite
    project_preference = @project.project_preferences.where(user_id: current_user.id).first_or_create
    project_preference.update favorited: (params[:favorited] == '1')
    redirect_to root_path
  end

  # POST /projects/1/archive
  def archive
    project_preference = @project.project_preferences.where(user_id: current_user.id).first_or_create
    project_preference.update archived: (params[:undo] != '1')
    redirect_to root_path, notice: archive_notice
  end

  # POST /projects/1/restore
  def restore
    project_preference = @project.project_preferences.where(user_id: current_user.id).first_or_create
    project_preference.update archived: (params[:undo] == '1')
    redirect_to archives_path, notice: restore_notice
  end

  # GET /archives
  def archives
    @projects = current_user.all_archived_projects.reorder('lower(name) asc').page(params[:page]).per(Project::PER_PAGE)
  end

  # GET /projects
  def index
    @order = scrub_order(Project, params[:order], 'projects.name')
    if @order == 'projects.name'
      @order = 'lower(projects.name) asc'
    elsif @order == 'projects.name desc'
      @order = 'lower(projects.name) desc'
    end
    @projects = current_user.all_viewable_projects.search(params[:search]).order(@order).page(params[:page]).per(40)
  end

  # GET /projects/1
  def show
    redirect_to project_subjects_path(@project)
  end

  # GET /projects/new
  def new
    @project = current_user.projects.new
  end

  # POST /projects
  def create
    @project = current_user.projects.new(project_params)
    if @project.save
      redirect_to settings_editor_project_path(@project), notice: 'Project was successfully created.'
    else
      render :new
    end
  end

  private

  # Overwriting application_controller
  def find_viewable_project_or_redirect
    super(:id)
  end

  def redirect_without_project
    super(projects_path)
  end

  # TODO: Reduce this list as it's only for initial project creation.
  def project_params
    params.require(:project).permit(
      :name, :slug, :description, :disable_all_emails,
      :collect_email_on_surveys, :hide_values_on_pdfs,
      :randomizations_enabled, :adverse_events_enabled, :blinding_enabled,
      :handoffs_enabled, :auto_lock_sheets,
      # Uploaded Logo
      :logo, :logo_uploaded_at, :logo_cache, :remove_logo,
      # Will automatically generate a site if the project has no site
      :site_name
    )
  end

  def restore_notice
    if params[:undo] == '1'
      'Your action has been undone.'
    else
      [
        "#{@project.name} has been restored.",
        { label: 'Undo', url: restore_project_path(@project, undo: '1'), method: :post }
      ]
    end
  end

  def archive_notice
    if params[:undo] == '1'
      'Your action has been undone.'
    else
      [
        "#{@project.name} has been archived.",
        { label: 'Undo', url: archive_project_path(@project, undo: '1'), method: :post }
      ]
    end
  end
end
