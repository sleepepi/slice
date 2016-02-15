# frozen_string_literal: true

# Allows project members to view and modify tasks on a project
class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_viewable_project,                  only: [:index, :show]
  before_action :set_editable_project_or_editable_site, only: [:new, :edit, :create, :update, :destroy]
  before_action :redirect_without_project
  before_action :set_viewable_task,                     only: [:show]
  before_action :set_editable_task,                     only: [:edit, :update, :destroy]
  before_action :redirect_without_task,                 only: [:show, :edit, :update, :destroy]

  # GET /projects/1/tasks
  def index
    @order = scrub_order(Task, params[:order], 'tasks.created_at DESC')
    @tasks = current_user.all_viewable_tasks
                         .where(project_id: @project.id)
                         .search(params[:search]).order(@order)
                         .page(params[:page]).per(40)
  end

  # GET /tasks/1
  def show
  end

  # GET /tasks/new
  def new
    @task = current_user.tasks.where(project_id: @project.id).new
  end

  # GET /tasks/1/edit
  def edit
  end

  # POST /tasks
  def create
    @task = current_user.tasks.where(project_id: @project.id).new(task_params)

    if @task.save
      redirect_to [@project, @task], notice: 'Task was successfully created.'
    else
      render :new
    end
  end

  # PATCH /tasks/1
  def update
    if @task.update(task_params)
      redirect_to [@project, @task], notice: 'Task was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /tasks/1
  def destroy
    @task.destroy
    redirect_to project_tasks_path(@project), notice: 'Task was successfully deleted.'
  end

  private

  def set_viewable_task
    @task = current_user.all_viewable_tasks.where(project_id: @project.id).find_by_id params[:id]
  end

  def set_editable_task
    @task = current_user.all_tasks.where(project_id: @project.id).find_by_id params[:id]
  end

  def redirect_without_task
    empty_response_or_root_path(project_tasks_path(@project)) unless @task
  end

  def task_params
    params[:task] ||= { blank: '1' }
    [:due_date, :window_start_date, :window_end_date].each do |date|
      params[:task][date] = parse_date(params[:task][date]) if params[:task].key?(date)
    end
    params.require(:task).permit(:description, :due_date, :window_start_date,
                                 :window_end_date, :completed, :only_unblinded)
  end
end
