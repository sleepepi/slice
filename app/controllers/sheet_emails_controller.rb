class SheetEmailsController < ApplicationController
  before_filter :authenticate_user!

  def show
    @project = current_user.all_viewable_and_site_projects.find_by_id(params[:project_id])
    @sheet_email = current_user.all_viewable_sheet_emails.find_by_id(params[:id])

    respond_to do |format|
      if @project and @sheet_email
        format.html # show.html.erb
        format.json { render json: @sheet_email }
      elsif @project
        format.html { redirect_to project_sheets_path(@project) }
        format.json { head :no_content }
      else
        format.html { redirect_to root_path }
        format.json { head :no_content }
      end
    end
  end
end
