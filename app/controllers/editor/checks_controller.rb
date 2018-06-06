# frozen_string_literal: true

# Allows project editors to create and update project checks.
class Editor::ChecksController < Editor::EditorController
  before_action :find_check_or_redirect, only: [
    :show, :edit, :update, :destroy, :request_run
  ]

  layout "layouts/full_page_sidebar"

  # GET /editor/projects/1/checks
  def index
    @checks = @project.checks.order(:archived, :name).page(params[:page]).per(40)
  end

  # # GET /editor/projects/1/checks/1
  # def show
  # end

  # GET /editor/projects/1/checks/new
  def new
    @check = current_user.checks.where(project_id: @project.id).new
  end

  # # GET /editor/projects/1/checks/1/edit
  # def edit
  # end

  # POST /editor/projects/1/checks
  def create
    @check = current_user.checks.where(project_id: @project.id).new(check_params)
    if @check.save
      redirect_to editor_project_check_path(@project, @check), notice: "Check was successfully created."
    else
      render :new
    end
  end

  # PATCH /editor/projects/1/checks/1
  # PATCH /editor/projects/1/checks/1.js
  def update
    if @check.update(check_params)
      respond_to do |format|
        format.html { redirect_to editor_project_check_path(@project, @check), notice: "Check was successfully updated." }
        format.js
      end
    else
      render :edit
    end
  end

  # POST /editor/projects/1/checks/1/request-run
  def request_run
    @check.update(last_run_at: nil)
    redirect_to editor_project_check_path(@project, @check), notice: "Check update requested."
  end

  # DELETE /editor/projects/1/checks/1
  # DELETE /editor/projects/1/checks/1.js
  def destroy
    @check.destroy
    respond_to do |format|
      format.html { redirect_to editor_project_checks_path(@project), notice: "Check was successfully deleted." }
      format.js
    end
  end

  private

  def find_check_or_redirect
    super(:id)
  end

  def check_params
    params.require(:check).permit(:name, :slug, :description, :message, :archived)
  end
end
