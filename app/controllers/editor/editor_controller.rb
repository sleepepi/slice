# frozen_string_literal: true

# Allows project editors to add values to check filters.
class Editor::EditorController < ApplicationController
  before_action :authenticate_user!
  before_action :find_editable_project_or_redirect

  private

  def find_check_or_redirect(id = :check_id)
    @check = @project.checks.find_by_param(params[id])
    redirect_without_check
  end

  def redirect_without_check
    empty_response_or_root_path(editor_project_checks_path(@project)) unless @check
  end

  def find_team_or_redirect(id = :ae_team_id)
    @team = @project.ae_teams.find_by_param(params[id])
    redirect_without_team
  end

  def redirect_without_team
    empty_response_or_root_path(editor_project_ae_teams_path(@project)) unless @team
  end
end
