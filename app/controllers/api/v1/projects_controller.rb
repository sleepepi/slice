# frozen_string_literal: true

# API to generate and retrieve a project's subjects and events.
class Api::V1::ProjectsController < Api::V1::BaseController
  before_action :find_project_or_redirect

  # # GET /api/v1/projects/1-AUTHENTICATION_TOKEN.json
  # def show
  # end

  # GET /api/v1/projects/1-AUTHENTICATION_TOKEN/survey-info.json
  def survey_info
    @event = @project.events.find_by_param(params[:event])
    @design = @project.designs.find_by_param(params[:design])
  end

  # # GET /api/v1/projects/1-AUTHENTICATION_TOKEN/subject-counts.json
  # def subject_counts
  # end

  # # GET /api/v1/projects/1-AUTHENTICATION_TOKEN/randomizations.json
  # def randomizations
  # end

  # # GET /api/v1/projects/1-AUTHENTICATION_TOKEN/expression.json
  # def expression
  # end

  # # GET /api/v1/projects/1-AUTHENTICATION_TOKEN/report-card.json
  # def report_card
  # end

  # # GET /api/v1/projects/1-AUTHENTICATION_TOKEN/data-checks.json
  # def data_checks
  # end
end
