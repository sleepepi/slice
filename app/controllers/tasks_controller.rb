# frozen_string_literal: true

# Allows project members to view and modify tasks on a project.
class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :find_viewable_project_or_redirect, only: [:index, :show]
  before_action :find_editable_project_or_editable_site_or_redirect, only: [
    :new, :edit, :create, :update, :destroy
  ]
  before_action :find_viewable_task_or_redirect, only: [:show]
  before_action :find_editable_task_or_redirect, only: [:edit, :update, :destroy]

  # GET /projects/1/tasks
  def index
    @order = scrub_order(Task, params[:order], 'tasks.created_at desc')
    @tasks = viewable_tasks.search(params[:search]).order(@order)
                           .page(params[:page]).per(40)
  end

  # # GET /tasks/1
  # def show
  # end

  # GET /tasks/new
  def new
    @task = current_user.tasks.where(project_id: @project.id).new
  end

  # # GET /tasks/1/edit
  # def edit
  # end

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

  def viewable_tasks
    current_user.all_viewable_tasks.where(project_id: @project.id)
  end

  def find_viewable_task_or_redirect
    @task = viewable_tasks.find_by(id: params[:id])
    redirect_without_task
  end

  def find_editable_task_or_redirect
    @task = current_user.all_tasks.where(project_id: @project.id).find_by(id: params[:id])
    redirect_without_task
  end

  def redirect_without_task
    empty_response_or_root_path(project_tasks_path(@project)) unless @task
  end

  def task_params
    params[:task] ||= { blank: '1' }
    parse_task_dates
    params.require(:task).permit(
      :description, :completed, :only_unblinded,
      :due_date, :window_start_date, :window_end_date
    )
  end

  def parse_task_dates
    parse_date_if_key_present(:task, :due_date)
    parse_date_if_key_present(:task, :window_start_date)
    parse_date_if_key_present(:task, :window_end_date)
  end
end
