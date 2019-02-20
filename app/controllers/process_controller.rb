# frozen_string_literal: true

# Allows variables on project to be formatted and validated.
class ProcessController < ApplicationController
  before_action :find_project_or_redirect
  before_action :find_variable_or_redirect

  # POST /process/:project_id/:variable_id/format.json
  def variable_format
    formatter = Formatters.for(@variable)
    @formatted_value = formatter.formatted(params[:value])
  end

  # POST /process/:project_id/:variable_id/validate.json
  def variable_validate
    I18n.locale = World.language
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
