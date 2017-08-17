# frozen_string_literal: true

# API to display and save surveys.
class Api::V1::SurveysController < Api::V1::BaseController
  before_action :find_project_or_redirect
  before_action :find_subject_or_redirect
  before_action :find_subject_sheet
  before_action :find_design_option, only: [:show_survey_page, :update_survey_response]

  # GET /api/v1/projects/1-AUTHENTICATION_TOKEN/subjects/1/surveys/:event/:design.json
  def show_survey
    if @event && @design && @subject_event && @sheet
      render :survey
    else
      head :no_content
    end
  end

  # GET /api/v1/projects/1-AUTHENTICATION_TOKEN/subjects/1/surveys/:event/:design/resume.json
  def resume_survey
    (@design_option, @page) = @sheet.find_next_design_option if @sheet
    if @sheet && @design_option
      @sheet_variable = @sheet.sheet_variables.find_by(variable: @design_option.variable)
      render :survey_page
    else
      head :no_content
    end
  end

  # GET /api/v1/projects/1-AUTHENTICATION_TOKEN/subjects/1/surveys/:event/:design/:page.json
  def show_survey_page
    if @event && @design && @design_option
      @sheet_variable = @sheet.sheet_variables.find_by(variable: @design_option.variable)
      render :survey_page
    else
      head :no_content
    end
  end

  # PATCH /api/v1/projects/1-AUTHENTICATION_TOKEN/subjects/1/surveys/:event/:design/:page.json
  def update_survey_response
    save_result = \
      if @design_option && @design_option.variable && !@design_option.variable.variable_type.in?(%w(calculated grid file signature))
        SheetTransaction.save_sheet!(
          @sheet, {}, { @design_option.variable_id.to_s => params[:response] },
          nil, params[:remote_ip], "api_sheet_update", partial_validation: true
        )
      elsif @design_option && @design_option.variable && @design_option.variable.variable_type.in?(%w(calculated grid file signature))
        true
      elsif @design_option && @design_option.section
        true
      end
    if save_result
      @sheet.update_associated_subject_events!
      @sheet.subject_event.update_coverage! if @sheet.subject_event
      render :survey_page, status: :ok
    else
      render :survey_page, status: :unprocessable_entity
    end
  end

  private

  def find_subject_sheet
    @event = @project.events.find_by_param(params[:event])
    @design = @project.designs.find_by_param(params[:design])
    @subject_event = @subject.subject_events.find_by(event: @event) if @event
    @sheet = find_or_create_sheet(@project, @subject, @subject_event, @design)
  end

  def find_or_create_sheet(project, subject, subject_event, design)
    return nil unless design && subject_event
    sheet = subject.sheets.find_by(design: design, subject_event: subject_event)
    return sheet if sheet
    sheet_params = { design_id: design.id, subject_event_id: subject_event.id }
    sheet = project.sheets.where(subject: subject).new(sheet_params)
    SheetTransaction.save_sheet!(sheet, sheet_params, {}, nil, params[:remote_ip], "api_sheet_create")
    sheet
  end

  def find_design_option
    @page = [params[:page].to_i, 1].max
    @design_option = @sheet.goto_page_number(@page) if @sheet
  end
end
