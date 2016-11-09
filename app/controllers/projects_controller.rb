# frozen_string_literal: true

# Allows projects to be viewed an edited.
class ProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_viewable_project_or_redirect, only: [
    :settings, :show, :collect, :team, :favorite, :activity, :logo,
    :archive, :calendar
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

  # GET /projects/1/calendar
  def calendar
    @anchor_date = (Date.parse(params[:date]) rescue Time.zone.today)
    @anchor_date = @anchor_date.beginning_of_week(:sunday)
    @weeks_before = -1
    @weeks_after = 4
    @first_date = @anchor_date + @weeks_before.week
    @last_date = (@anchor_date + @weeks_after.week) + 6.days

    @tasks = current_user.all_viewable_tasks.where(project_id: @project.id, due_date: @first_date..@last_date).to_a
    @randomizations = current_user.all_viewable_randomizations.where(project_id: @project.id).where('DATE(randomized_at) IN (?)', @first_date..@last_date).to_a
    @adverse_events = current_user.all_viewable_adverse_events.where(project_id: @project.id, adverse_event_date: @first_date..@last_date).to_a
    @comments = current_user.all_viewable_comments.joins(:sheet).where(sheets: { project_id: @project.id }).where('DATE(comments.created_at) IN (?)', @first_date..@last_date).to_a
    @subject_events = SubjectEvent.joins(:subject, :event).merge(current_user.all_viewable_subjects.where(project_id: @project.id)).merge(current_user.all_viewable_events.where(project_id: @project.id)).where(event_date: @first_date..@last_date).to_a
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
    @order = scrub_order(Subject, params[:order], 'subjects.subject_code')
    subject_scope = current_user.all_viewable_subjects.where(project_id: @project.id)
                                .search(params[:search]).order(@order)
    @subjects = subject_scope.page(params[:page]).per(20)
    @tokens = []
    # redirect_to project_subjects_path(@project)
  end

  # GET /projects/new
  def new
    @project = current_user.projects.new
  end

  # POST /projects
  def create
    @project = current_user.projects.new(project_params)
    if @project.save
      redirect_to setup_project_sites_path(@project), notice: 'Project was successfully created.'
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
      :name, :slug, :description,
      # Uploaded Logo
      :logo, :logo_uploaded_at, :logo_cache, :remove_logo
    )
  end

  def archive_notice
    if params[:undo] == '1'
      'Your action has been undone.'
    else
      [
        'Project archived.',
        { label: 'Undo', url: archive_project_path(@project, undo: '1'), method: :post }
      ]
    end
  end
end
