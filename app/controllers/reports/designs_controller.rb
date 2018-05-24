# frozen_string_literal: true

# reports/designs/:design_id/          <= Basic Quick-Glance Report Statistics
# reports/designs/:design_id/overview  <= Overview Report

# Displays basic, overview, and advanced reports for designs, as well as
# providing PDFs of the reports.
class Reports::DesignsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_viewable_project_or_redirect
  before_action :find_viewable_design

  layout "layouts/full_page_sidebar"

  # def basic
  # end

  # GET /reports/designs/1/overview
  def overview
    @event = @design.events.find_by(id: params[:event_id]) if @design.events.count > 1
    sheet_scope = current_user.all_viewable_sheets
                              .where(project_id: @project.id, design_id: @design.id)
                              .where(missing: false)
    sheet_scope = sheet_scope.includes(:subject_event).where(subject_events: { event_id: @event.id }) if @event
    @sheets = sheet_scope
  end

  protected

  def find_viewable_design
    @design = current_user.all_viewable_designs.where(project_id: @project.id).find_by_param(params[:id])
    redirect_without_design
  end

  def redirect_without_design
    empty_response_or_root_path(project_designs_path(@project)) unless @design
  end
end
