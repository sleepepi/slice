# frozen_string_literal: true

# Allows project editors to create and update grid variables.
class Editor::GridVariablesController < Editor::EditorController
  before_action :set_grid_variable, only: [:show, :edit, :update, :destroy]

  # GET /grid-variables
  def index
    @grid_variables = @project.grid_variables
                              .order(:parent_variable_id, :position)
                              .page(params[:page]).per(40)
  end

  # GET /grid-variables/1
  def show
  end

  # GET /grid-variables/new
  def new
    @grid_variable = @project.grid_variables.new
  end

  # GET /grid-variables/1/edit
  def edit
  end

  # POST /grid-variables
  def create
    @grid_variable = @project.grid_variables.new(grid_variable_params)
    if @grid_variable.save
      redirect_to editor_project_grid_variable_path(@project, @grid_variable), notice: 'Grid variable was successfully created.'
    else
      render :new
    end
  end

  # PATCH /grid-variables/1
  def update
    if @grid_variable.update(grid_variable_params)
      redirect_to editor_project_grid_variable_path(@project, @grid_variable), notice: 'Grid variable was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /grid-variables/1
  def destroy
    @grid_variable.destroy
    redirect_to editor_project_grid_variables_path(@project), notice: 'Grid variable was successfully deleted.'
  end

  private

  def set_grid_variable
    @grid_variable = @project.grid_variables.find_by_id params[:id]
  end

  def grid_variable_params
    params.require(:grid_variable).permit(:parent_variable_id, :child_variable_id, :position)
  end
end
