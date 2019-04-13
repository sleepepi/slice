# frozen_string_literal: true

# Allows public surveys to be filled out.
class SurveyController < ApplicationController
  prepend_before_action { request.env["devise.skip_timeout"] = true }
  skip_before_action :verify_authenticity_token
  before_action :find_public_design_or_redirect, only: [:new, :edit, :create, :update]
  before_action :find_or_create_subject, only: [:create]
  before_action :find_sheet_or_redirect, only: [:edit, :update]
  before_action :redirect_on_auto_locked_sheet, only: [:edit, :update]

  layout "layouts/minimal_layout"

  # GET /survey
  def index
    render layout: "layouts/application"
  end

  # GET /survey/:slug
  def new
    @sheet = @project.sheets.new
  end

  # # GET /survey/:slug/:sheet_authentication_token
  # def edit
  # end

  # POST /survey/:slug
  def create
    @sheet = @project.sheets.where(design_id: @design.id).new(sheet_params)
    if SheetTransaction.save_sheet!(@sheet, {}, variables_params, nil, request.remote_ip, "public_sheet_create")
      @sheet.update_coverage!
      send_survey_completion_emails
      redirect_to survey_redirect_page
    else
      render :new
    end
  end

  # PATCH /survey/:slug/:sheet_authentication_token
  def update
    if SheetTransaction.save_sheet!(@sheet, {}, variables_params, nil, request.remote_ip, "public_sheet_update")
      @sheet.update_coverage!
      redirect_to survey_redirect_page
    else
      render :edit
    end
  end

  private

  def find_public_design_or_redirect
    @design = Design.current.where(publicly_available: true).find_by(survey_slug: params[:slug])
    @project = @design.project if @design
    redirect_without_design
  end

  def find_or_create_subject
    @subject = @project.subjects.find_by(id: params[:subject_id])
    @subject = @project.create_valid_subject(params[:site_id]) unless @subject
  end

  def redirect_without_design
    return if @design

    flash[:alert] = "This survey no longer exists."
    empty_response_or_root_path(about_survey_path)
  end

  def find_sheet_or_redirect
    return if params[:sheet_authentication_token].blank?

    @sheet = @design.sheets.find_by(authentication_token: params[:sheet_authentication_token])
    redirect_without_sheet
  end

  def redirect_without_sheet
    return if @sheet

    flash[:alert] = "This survey no longer exists."
    empty_response_or_root_path(about_survey_path(survey: @design.survey_slug))
  end

  def redirect_on_auto_locked_sheet
    return unless @sheet.auto_locked?

    flash[:alert] = "This survey has been locked."
    empty_response_or_root_path(about_survey_path(survey: @design.survey_slug))
  end

  def sheet_params
    {
      subject_id: @subject.id,
      authentication_token: SecureRandom.hex(8),
      last_edited_at: Time.zone.now
    }
  end

  def variables_params
    (params[:variables].blank? ? {} : params.require(:variables).permit!)
  end

  def survey_redirect_page
    @design.redirect_url.presence || about_survey_path(survey: @design.survey_slug, a: @sheet.authentication_token)
  end

  # TODO: Survey completion emails should be sent differently or done as in-app notifications to project editors
  def send_survey_completion_emails
    return unless EMAILS_ENABLED

    UserMailer.survey_completed(@sheet).deliver_now
  end
end
