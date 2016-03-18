# frozen_string_literal: true

# Allows site viewers to request that sheets be unlocked.
class SheetUnlockRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_editable_project_or_editable_site_or_redirect
  before_action :find_editable_sheet_or_redirect
  before_action :find_sheet_unlock_request_or_redirect, only: [:destroy]

  # POST /unlock/requests.js
  def create
    @sheet_unlock_request = current_user.sheet_unlock_requests
                                        .where(sheet_id: @sheet.id)
                                        .new(sheet_unlock_request_params)

    if @sheet_unlock_request.save
      render :create
    else
      render :new
    end
  end

  # DELETE /unlock/requests/1
  def destroy
    @sheet_unlock_request.destroy
    redirect_to [@project, @sheet], notice: 'Sheet unlock request was successfully deleted.'
  end

  private

  def find_editable_sheet_or_redirect
    @sheet = current_user.all_sheets.find_by_id params[:sheet_id]
    redirect_without_sheet
  end

  def redirect_without_sheet
    empty_response_or_root_path(project_sheets_path(@project)) unless @sheet
  end

  def find_sheet_unlock_request_or_redirect
    @sheet_unlock_request = if @project.editable_by?(current_user)
                              @sheet.sheet_unlock_requests.find_by_id params[:id]
                            else
                              @sheet.sheet_unlock_requests
                                    .where(user_id: current_user.id)
                                    .find_by_id params[:id]
                            end
    empty_response_or_root_path([@project, @sheet]) unless @sheet_unlock_request
  end

  def sheet_unlock_request_params
    params.require(:sheet_unlock_request).permit(:reason)
  end
end
