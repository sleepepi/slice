# frozen_string_literal: true

# Allows creation and resolution of information requests.
class AeModule::SheetsController < AeModule::BaseController
  before_action :find_project_as_reporter_or_admin_or_team_member_or_redirect
  before_action :redirect_blinded_users
  before_action :find_adverse_event_or_redirect
  before_action :find_sheet_or_redirect, only: [:show]
  before_action :set_project_member
  layout :sidebar_layout

  # GET /projects/:project_id/ae-module/adverse-events/:adverse_event_id/sheets/:id
  # GET /projects/:project_id/ae-module/adverse-events/:adverse_event_id/sheets/:id.pdf
  def show
    generate_pdf if params[:format] == "pdf"
  end

  private

  def generate_pdf
    sheet_print = @sheet.sheet_prints.where(language: World.language).first_or_create
    sheet_print.regenerate! if sheet_print.regenerate?
    send_file_if_present sheet_print.file, type: "application/pdf", disposition: "inline"
  end

  def find_sheet_or_redirect
    @sheet = @adverse_event.sheets.find_by(id: params[:id])
    @ae_sheet = @adverse_event.ae_sheets.find_by(sheet: @sheet)
    empty_response_or_root_path(ae_module_adverse_event_path(@project, @adverse_event)) unless @sheet && @ae_sheet
  end
end
