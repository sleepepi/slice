# frozen_string_literal: true

# API to generate and retrieve a subject's events and sheets.
class Api::V1::SubjectsController < Api::V1::BaseController
  before_action :find_project_or_redirect
  before_action :find_subject_or_redirect, only: [:show, :events, :create_event]

  # # GET /api/v1/projects/1-AUTHENTICATION_TOKEN/subjects/1.json
  # def show
  # end

  # # GET /api/v1/projects/1-AUTHENTICATION_TOKEN/subjects/1/events.json
  # def events
  # end

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
      render :events, status: :created
    else
      render json: @subject_event.errors, status: :unprocessable_entity
    end
  end

  private

  def find_subject_or_redirect
    @subject = @project.subjects.find_by(id: params[:id])
    head :no_content unless @subject
  end

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
