# frozen_string_literal: true

# API to generate and retrieve a project's subjects and events.
class Api::V1::ReportsController < Api::V1::BaseController
  before_action :find_project_or_redirect
  before_action :find_event_or_redirect
  before_action :find_design_or_redirect
  before_action :find_subject, only: :show # Optional
  before_action :find_subject_or_redirect, only: :review # Not optional

  # GET /api/v1/projects/1-AUTHENTICATION_TOKEN/reports/:event/:design.json
  def show
    sheet_scope = \
      @project.sheets.where(design: @design).where(missing: false)
              .includes(:subject_event).where(subject_events: { event: @event })
    @sheets = sheet_scope
  end

  # GET /api/v1/projects/1-AUTHENTICATION_TOKEN/reports/review/:event/:design.json
  def review
    if @subject
      sheet_scope = \
        @project.sheets.where(design: @design).where(missing: false)
                .includes(:subject_event).where(subject_events: { event: @event })

      @sheet = sheet_scope.find_by(subject: @subject)
    else
      head :no_content
    end
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

  def find_subject
    @subject = @project.subjects.find_by(id: params[:subject_id])
  end

  def find_subject_or_redirect
    @subject = @project.subjects.find_by(id: params[:subject_id])
    head :no_content unless @subject
  end
end
