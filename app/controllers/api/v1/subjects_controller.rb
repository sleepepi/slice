# frozen_string_literal: true

# API to generate and retrieve a subject's events and sheets.
class Api::V1::SubjectsController < Api::V1::BaseController
  before_action :find_project_or_redirect
  before_action :find_subject_or_redirect, only: [:show, :events]

  # # GET /api/v1/projects/1-AUTHENTICATION_TOKEN/subjects/1.json
  # def show
  # end

  # # GET /api/v1/projects/1-AUTHENTICATION_TOKEN/subjects/1/events.json
  # def events
  # end

  private

  def find_subject_or_redirect
    Rails.logger.debug "params[:id]: #{params[:id]}"
    @subject = @project.subjects.find_by(id: params[:id])
    head :no_content unless @subject
  end
end
