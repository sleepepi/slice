class ValidateController < ApplicationController

  before_action :set_project
  before_action :redirect_without_project

  before_action :set_variable
  before_action :redirect_without_variable

  def variable
    render json: @variable.value_in_range?(params[:value])
  end

  private

    def set_project
      @project = Project.current.find_by_param(params[:project_id])
    end

    def redirect_without_project
      empty_response_or_root_path unless @project
    end

    def set_variable
      @variable = @project.variables.find_by_id(params[:variable_id])
    end

    def redirect_without_variable
      empty_response_or_root_path unless @variable
    end
end

