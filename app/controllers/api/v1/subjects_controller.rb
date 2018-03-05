# frozen_string_literal: true

# API to generate and retrieve a subject's events and sheets.
class Api::V1::SubjectsController < Api::V1::BaseController
  before_action :find_project_or_redirect
  before_action :find_subject_or_redirect, only: [
    :show, :events, :create_event, :create_sheet, :data
  ]

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

  # GET /api/v1/projects/1-AUTHENTICATION_TOKEN/subjects/1/data.json
  def data
    data_points = []
    params[:data_points].each do |hash_or_string|
      if hash_or_string.is_a?(ActionController::Parameters)
        event_slug = hash_or_string[:event]
        variable_name = hash_or_string[:variable]
      else
        event_slug = nil
        variable_name = hash_or_string
      end
      data_points << { variable_name: variable_name, event_slug: event_slug }
    end
    @data = {}
    @variables = @project.variables.where(name: data_points.collect { |a| a.dig(:variable_name) }).to_a
    @events = @project.events.where(slug: data_points.collect { |a| a.dig(:event_slug) }).to_a
    data_points.each do |hash|
      variable = @variables.find { |v| v.name == hash[:variable_name] }
      event = @events.find { |e| e.slug == hash[:event_slug] }
      if event
        @data[hash[:event_slug].to_s] ||= {}
        @data[hash[:event_slug].to_s][hash[:variable_name].to_s] = (variable ? @subject.response_for_variable(variable, event: event) : nil)
      else
        @data[hash[:variable_name].to_s] = (variable ? @subject.response_for_variable(variable, event: event) : nil)
      end
    end
    @data
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
