# Allows variables on project to be validated
class ValidateController < ApplicationController
  before_action :set_project
  before_action :set_variable

  def variable
    render json: @variable.value_in_range?(params[:value])
  end

  private

  def set_project
    @project = Project.current.find_by_param params[:project_id]
    empty_response_or_root_path unless @project
  end

  def set_variable
    @variable = @project.variables.find_by_id params[:variable_id]
    empty_response_or_root_path unless @variable
  end
end
