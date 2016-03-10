# frozen_string_literal: true

# Allows public surveys to be filled out.
class SurveyController < ApplicationController
  prepend_before_action { request.env['devise.skip_timeout'] = true }
  skip_before_action :verify_authenticity_token
  before_action :find_public_design_or_redirect, only: [:new, :edit, :create, :update]
  before_action :find_or_create_subject, only: [:create]
  before_action :find_sheet_or_redirect, only: [:edit, :update]
  before_action :redirect_on_locked_sheet, only: [:edit, :update]

  layout 'layouts/minimal_layout'

  def index
  end

  def new
    @sheet = @project.sheets.new
  end

  def edit
  end

  def create
    @sheet = @project.sheets.where(design_id: @design.id)
                     .new(subject_id: @subject.id, authentication_token: SecureRandom.hex(8))
    if SheetTransaction.save_sheet!(@sheet, {}, variables_params, nil, request.remote_ip, 'public_sheet_create')
      send_survey_completion_emails
      redirect_to survey_redirect_page
    else
      render :new
    end
  end

  def update
    if SheetTransaction.save_sheet!(@sheet, {}, variables_params, nil, request.remote_ip, 'public_sheet_update')
      redirect_to about_survey_path(survey: @design.slug, a: @sheet.authentication_token)
    else
      render :edit
    end
  end

  private

  def find_public_design_or_redirect
    @design = Design.current.where(publicly_available: true).find_by_slug params[:slug]
    @project = @design.project if @design
    redirect_without_design
  end

  def find_or_create_subject
    @subject = @project.subjects.find_by_id(params[:subject_id])
    @subject = @project.create_valid_subject(params[:email], params[:site_id]) unless @subject
  end

  def redirect_without_design
    return if @design
    flash[:alert] = 'This survey no longer exists.'
    empty_response_or_root_path(about_survey_path)
  end

  def find_sheet_or_redirect
    return if params[:sheet_authentication_token].blank?
    @sheet = @design.sheets.find_by_authentication_token params[:sheet_authentication_token]
    redirect_without_sheet
  end

  def redirect_without_sheet
    return if @sheet
    flash[:alert] = 'This survey no longer exists.'
    empty_response_or_root_path(about_survey_path(survey: @design.slug))
  end

  def redirect_on_locked_sheet
    return unless @sheet.locked?
    flash[:alert] = 'This survey has been locked.'
    empty_response_or_root_path(about_survey_path(survey: @design.slug))
  end

  def variables_params
    (params[:variables].blank? ? {} : params.require(:variables).permit!)
  end

  def survey_redirect_page
    if @design.redirect_url.blank?
      about_survey_path(survey: @design.slug, a: @sheet.authentication_token)
    else
      @design.redirect_url
    end
  end

  def send_survey_completion_emails
    return unless EMAILS_ENABLED
    UserMailer.survey_completed(@sheet).deliver_later
    UserMailer.survey_user_link(@sheet).deliver_later unless @subject.email.blank?
  end
end
