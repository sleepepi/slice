# frozen_string_literal: true

# Allows project editors to create and update project checks.
class Editor::ChecksController < ApplicationController
  before_action :authenticate_user!
  before_action :find_editable_project_or_redirect
  before_action :find_check_or_redirect, only: [:show, :edit, :update, :destroy]

  # GET /editor/projects/1/checks
  def index
    @checks = @project.checks.order(:archived, :name).page(params[:page]).per(40)
  end

  # GET /editor/projects/1/checks/1
  def show
  end

  # GET /editor/projects/1/checks/new
  def new
    @check = current_user.checks.where(project_id: @project.id).new
  end

  # GET /editor/projects/1/checks/1/edit
  def edit
  end

  # POST /editor/projects/1/checks
  def create
    @check = current_user.checks.where(project_id: @project.id).new(check_params)
    if @check.save
      redirect_to editor_project_check_path(@project, @check), notice: 'Check was successfully created.'
    else
      render :new
    end
  end

  # PATCH /editor/projects/1/checks/1
  def update
    if @check.update(check_params)
      redirect_to editor_project_check_path(@project, @check), notice: 'Check was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /editor/projects/1/checks/1
  def destroy
    @check.destroy
    redirect_to editor_project_checks_path(@project), notice: 'Check was successfully deleted.'
  end

  private

  def find_check_or_redirect
    @check = @project.checks.find_by_param params[:id]
    redirect_without_check
  end

  def redirect_without_check
    empty_response_or_root_path(editor_project_checks_path(@project)) unless @check
  end

  def check_params
    params.require(:check).permit(:name, :slug, :description, :archived)
  end
end
