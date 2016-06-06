# frozen_string_literal: true

# Allows projects to be viewed an edited.
class ProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_viewable_project_or_redirect, only: [
    :settings, :show, :collect, :share, :about, :favorite, :activity, :logo,
    :archive, :restore
  ]

  # POST /projects/save_project_order.js
  def save_project_order
    page = [params[:page].to_i, 1].max
    params[:project_ids].each_with_index do |project_id, index|
      project_favorite = current_user.project_favorites.where(project_id: project_id).first_or_create
      project_favorite.update position: ((page - 1) * Project::PER_PAGE) + index
    end
    render nothing: true
  end

  # GET /projects/1/logo
  def logo
    send_file File.join(CarrierWave::Uploader::Base.root, @project.logo.url)
  end

  # POST /projects/1/favorite
  def favorite
    project_favorite = @project.project_favorites.where(user_id: current_user.id).first_or_create
    project_favorite.update favorite: (params[:favorite] == '1')
    redirect_to root_path
  end

  # POST /projects/1/archive
  def archive
    project_favorite = @project.project_favorites.where(user_id: current_user.id).first_or_create
    project_favorite.update archived: (params[:undo] != '1')
    redirect_to root_path, notice: archive_notice
  end

  # POST /projects/1/restore
  def restore
    project_favorite = @project.project_favorites.where(user_id: current_user.id).first_or_create
    project_favorite.update archived: (params[:undo] == '1')
    redirect_to archives_path, notice: restore_notice
  end

  # GET /projects/search
  def search
    @subjects = current_user.all_viewable_subjects.search(params[:q]).order('subject_code').limit(10)
    @projects = current_user.all_viewable_projects.search(params[:q]).order('name').limit(10)
    @designs = current_user.all_viewable_designs.search(params[:q]).order('name').limit(10)
    @variables = current_user.all_viewable_variables.search(params[:q]).order('name').limit(10)

    @objects = @subjects + @projects + @designs + @variables

    respond_to do |format|
      format.json { render json: ([params[:q]] + @objects.collect(&:name)).uniq }
      format.html do
        redirect_to [@objects.first.project, @objects.first] if @objects.size == 1 && @objects.first.respond_to?('project')
        redirect_to @objects.first if @objects.size == 1 && !@objects.first.respond_to?('project')
      end
    end
  end

  # GET /projects/1/splash
  # GET /projects/1/splash.js
  def splash
    flash.delete(:notice) if flash[:notice] == 'Signed in successfully.'

    if session[:invite_token].present?
      redirect_to accept_project_users_path
      return
    elsif session[:site_invite_token].present?
      site_invite_token = session[:site_invite_token]
      @site_user = SiteUser.find_by_invite_token(site_invite_token)
      if @site_user
        redirect_to accept_project_site_users_path(@site_user.project)
      else
        session[:site_invite_token] = nil
        redirect_to root_path, alert: 'Invalid invitation token.'
      end
      return
    end

    @projects = current_user.all_viewable_and_site_projects.by_favorite(current_user.id).unarchived.order("(favorite IS NULL or favorite = 'f') ASC, position, name").page(params[:page]).per( Project::PER_PAGE )

    @favorited_projects = @projects.where(project_favorites: { favorite: true })
    @current_projects = @projects.where(project_favorites: { favorite: [false, nil] }).reorder(:name)

    redirect_to @projects.first if current_user.all_viewable_and_site_projects.count == 1
  end

  # GET /archives
  def archives
    @projects = current_user.all_archived_projects.order(:name).page(params[:page]).per(Project::PER_PAGE)
  end

  # GET /projects
  def index
    @order = scrub_order(Project, params[:order], 'projects.name')
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
      redirect_to @project, notice: 'Project was successfully created.'
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

  def project_params
    params.require(:project).permit(
      :name, :slug, :description, :subject_code_name, :show_contacts,
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

  def restore_notice
    if params[:undo] == '1'
      'Your action has been undone.'
    else
      "#{view_context.link_to(@project.name, @project)} has been restored.\
       #{view_context.link_to 'Undo', restore_project_path(@project, undo: '1'), method: :post}"
    end
  end

  def archive_notice
    if params[:undo] == '1'
      'Your action has been undone.'
    else
      "#{view_context.link_to(@project.name, @project)} has been archived.\
       #{view_context.link_to 'Undo', archive_project_path(@project, undo: '1'), method: :post}"
    end
  end
end
