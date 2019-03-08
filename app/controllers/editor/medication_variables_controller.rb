# frozen_string_literal: true

# Allows project editors to specify medication module variables to collect.
class Editor::MedicationVariablesController < Editor::EditorController
  before_action :find_medication_variable_or_redirect, only: [:show, :edit, :update, :destroy]

  layout "layouts/full_page_sidebar_dark"

  # GET /editor/projects/:project_id/medication_variables
  def index
    scope = @project.medication_variables.search_any_order(params[:search])
    @medication_variables = scope.page(params[:page]).per(20)
  end

  # # GET /editor/projects/:project_id/medication_variables/:id
  # def show
  # end

  # GET /editor/projects/:project_id/medication_variables/new
  def new
    @medication_variable = @project.medication_variables.new
  end

  # # GET /editor/projects/:project_id/medication_variables/:id/edit
  # def edit
  # end

  # POST /editor/projects/:project_id/medication_variables
  def create
    @medication_variable = @project.medication_variables.new(medication_variable_params)
    if @medication_variable.save
      redirect_to editor_project_medication_variable_path(@project, @medication_variable),
                  notice: "Medication variable was successfully created."
    else
      render :new
    end
  end

  # PATCH /editor/projects/:project_id/medication_variables/:id
  def update
    if @medication_variable.update(medication_variable_params)
      redirect_to editor_project_medication_variable_path(@project, @medication_variable),
                  notice: "Medication variable was successfully updated."
    else
      render :edit
    end
  end

  # DELETE /editor/projects/:project_id/medication_variables/:id
  def destroy
    @medication_variable.destroy
    redirect_to editor_project_medication_variables_path(@project),
                notice: "Medication variable was successfully deleted."
  end

  private

  def find_medication_variable_or_redirect
    @medication_variable = @project.medication_variables.find_by(id: params[:id])
  end

  def medication_variable_params
    params.require(:medication_variable).permit(:name, :autocomplete_values)
  end
end
