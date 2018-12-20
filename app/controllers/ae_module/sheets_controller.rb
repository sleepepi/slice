# frozen_string_literal: true

# Allows creation and resolution of information requests.
class AeModule::SheetsController < AeModule::BaseController
  before_action :find_review_admin_project_or_reporter_project_or_redirect
  before_action :redirect_blinded_users
  before_action :find_adverse_event_or_redirect
  before_action :find_sheet_or_redirect, only: [:show]

  # GET /projects/:project_id/ae-module/adverse-events/:adverse_event_id/sheets/:id
  def show
  end

  private

  def find_review_admin_project_or_reporter_project_or_redirect
    project = Project.current.find_by_param(params[:project_id])
    if project.ae_admin?(current_user)
      @project = project
    elsif project.ae_reporter?(current_user)
      @project = project
    else
      redirect_without_project
    end
  end

  def find_sheet_or_redirect
    @sheet = @adverse_event.sheets.find_by(id: params[:id])
    empty_response_or_root_path(ae_module_adverse_event_path(@project, @adverse_event)) unless @sheet
  end
end
