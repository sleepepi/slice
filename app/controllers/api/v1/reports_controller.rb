# frozen_string_literal: true

# API to generate and retrieve a project's subjects and events.
class Api::V1::ReportsController < Api::V1::BaseController
  before_action :find_project_or_redirect
  before_action :find_event_or_redirect
  before_action :find_design_or_redirect

  # GET /api/v1/projects/1-AUTHENTICATION_TOKEN/reports/:event/:design.json
  def show
    sheet_scope = \
      @project.sheets.where(design: @design).where(missing: false)
              .includes(:subject_event).where(subject_events: { event: @event })
    @sheets = sheet_scope
  end

  private

  def find_event_or_redirect
    @event = @project.events.find_by_param(params[:event])
    head :no_content unless @event
  end

  def find_design_or_redirect
    @design = @project.designs.find_by_param(params[:design])
    head :no_content unless @design
  end
end
