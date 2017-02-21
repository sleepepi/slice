# frozen_string_literal: true

# Allows variables on project to be validated
class ValidateController < ApplicationController
  before_action :find_project_or_redirect
  before_action :find_variable_or_redirect

  # POST /validate/variable.json
  def variable
    render json: @variable.value_in_range?(params[:value])
  end

  private

  def find_project_or_redirect
    @project = Project.current.find_by_param(params[:project_id])
    empty_response_or_root_path unless @project
  end

  def find_variable_or_redirect
    @variable = @project.variables.find_by(id: params[:variable_id])
    empty_response_or_root_path unless @variable
  end
end
