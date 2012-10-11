class SheetEmailsController < ApplicationController
  before_filter :authenticate_user!

  def show
    @sheet_email = current_user.all_viewable_sheet_emails.find_by_id(params[:id])

    respond_to do |format|
      if @sheet_email
        format.html # show.html.erb
        format.json { render json: @sheet_email }
      else
        format.html { redirect_to sheets_path }
        format.json { head :no_content }
      end
    end
  end
end
