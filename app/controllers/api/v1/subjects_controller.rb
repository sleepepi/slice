# frozen_string_literal: true

# API to generate and retrieve a subject's events and sheets.
class Api::V1::SubjectsController < Api::V1::BaseController
  before_action :find_project_or_redirect
  before_action :find_subject_or_redirect, only: [:show, :events, :create_event, :create_sheet]

  # GET /api/v1/projects/1-AUTHENTICATION_TOKEN/subjects.json
  def index
    @subjects = @project.subjects.page(params[:page]).per(20)
  end

  # # GET /api/v1/projects/1-AUTHENTICATION_TOKEN/subjects/1.json
  # def show
  # end

  # GET /api/v1/projects/1-AUTHENTICATION_TOKEN/subjects/1/events.json
  def events
    @subject.sheets.each(&:check_coverage)
    @subject.subject_events.each(&:check_coverage)
  end

  # POST /api/v1/projects/1-AUTHENTICATION_TOKEN/subjects.json
  def create
    @subject = @project.subjects.new(subject_params)
    if @subject.save
      render :show, status: :created
    else
      render json: @subject.errors, status: :unprocessable_entity
    end
  end

  # POST /api/v1/projects/1-AUTHENTICATION_TOKEN/subjects/1/events.json
  def create_event
    @event = @project.events.find_by_param(params[:event_id])
    @subject_event = @subject.subject_events.where(event: @event).new(event_date: Time.zone.today)
    if @subject_event.save
      @subject_event.update_coverage!
      render :events, status: :created
    else
      render json: @subject_event.errors, status: :unprocessable_entity
    end
  end

  # POST /api/v1/projects/1-AUTHENTICATION_TOKEN/subjects/1/sheets.json
  def create_sheet
    design = @project.designs.find_by(id: params[:design_id])
    subject_event = @subject.subject_events.find_by(id: params[:subject_event_id])
    sheet_params = {}
    if design && subject_event
      sheet_params = { design_id: design.id, subject_event_id: subject_event.id }
      @sheet = @subject.sheets.find_by(design: design, subject_event_id: subject_event)
    end
    if @sheet
      render :sheet
    else
      @sheet = @project.sheets.where(subject: @subject).new(sheet_params)
      if SheetTransaction.save_sheet!(@sheet, sheet_params, {}, nil, params[:remote_ip], "api_sheet_create")
        @sheet.set_token
        render :sheet, status: :created
      else
        render json: @sheet.errors, status: :unprocessable_entity
      end
    end
  end

  private

  def subject_params
    params[:subject] ||= { blank: "1" }
    params[:subject][:site_id] = clean_site_id
    params.require(:subject).permit(:subject_code, :site_id)
  end

  def clean_site_id
    site = @project.sites.find_by(id: params[:subject][:site_id])
    site ? site.id : nil
  end
end
