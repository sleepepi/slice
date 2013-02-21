class SheetEmailsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :set_viewable_project
  before_filter :redirect_without_project
  before_filter :set_viewable_sheet_email
  before_filter :redirect_without_sheet_email

  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @sheet_email }
    end
  end

  private

  def set_viewable_sheet_email
    @sheet_email = current_user.all_viewable_sheet_emails.find_by_id(params[:id])
  end

  def redirect_without_sheet_email
    empty_response_or_root_path(project_sheets_path(@project)) unless @sheet_email
  end

end
