# frozen_string_literal: true

# Allows project editors to create and update project check filters.
class Editor::CheckFiltersController < Editor::EditorController
  before_action :find_check_or_redirect
  before_action :find_filter_or_redirect, only: [:show, :edit, :update, :destroy]

  layout "layouts/full_page_sidebar"

  # GET /editor/projects/1/checks/1/filters
  def index
    @check_filters = @check.check_filters.order(:position).page(params[:page]).per(40)
  end

  # # GET /editor/projects/1/checks/1/filters/1
  # def show
  # end

  # GET /editor/projects/1/checks/1/filters/new
  def new
    @check_filter = @check.check_filters.new
  end

  # # GET /editor/projects/1/checks/1/filters/1/edit
  # def edit
  # end

  # POST /editor/projects/1/checks/1/filters
  def create
    @check_filter = current_user.check_filters
                                .where(project_id: @project.id, check_id: @check.id)
                                .new(check_filter_params)
    if @check_filter.save
      redirect_to editor_project_check_check_filter_path(
        @project, @check, @check_filter
      ), notice: "Filter was successfully created."
    else
      render :new
    end
  end

  # PATCH /editor/projects/1/checks/1/filters/1
  def update
    if @check_filter.update(check_filter_params)
      redirect_to editor_project_check_check_filter_path(
        @project, @check, @check_filter
      ), notice: "Filter was successfully updated."
    else
      render :edit
    end
  end

  # DELETE /editor/projects/1/checks/1/filters/1
  def destroy
    @check_filter.destroy
    redirect_to editor_project_check_check_filters_path(@project, @check),
                notice: "Filter was successfully deleted."
  end

  private

  def find_filter_or_redirect
    super(:id)
  end

  def check_filter_params
    params.require(:check_filter).permit(:filter_type, :variable_id, :operator, :position)
  end
end
