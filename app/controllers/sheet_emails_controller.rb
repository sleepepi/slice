class SheetEmailsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_viewable_project
  before_action :redirect_without_project
  before_action :set_viewable_sheet_email
  before_action :redirect_without_sheet_email

  # GET /sheet_emails/1
  # GET /sheet_emails/1.json
  def show
  end

  private

    def set_viewable_sheet_email
      @sheet_email = current_user.all_viewable_sheet_emails.find_by_id(params[:id])
    end

    def redirect_without_sheet_email
      empty_response_or_root_path(project_sheets_path(@project)) unless @sheet_email
    end

end
