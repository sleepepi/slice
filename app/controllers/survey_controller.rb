# frozen_string_literal: true

class SurveyController < ApplicationController
  prepend_before_action { request.env['devise.skip_timeout'] = true }
  skip_before_action :verify_authenticity_token

  before_action :set_public_design,         only: [:new, :edit, :create, :update]
  before_action :redirect_without_design,   only: [:new, :edit, :create, :update]
  before_action :set_sheet,                 only: [:edit, :update]
  before_action :redirect_without_sheet,    only: [:edit, :update]
  before_action :redirect_on_locked_sheet,  only: [:edit, :update]

  layout 'layouts/minimal_layout'

  def index
  end

  def new
    @sheet = @project.sheets.new
  end

  def edit
  end

  def create
    @subject = @project.subjects.find_by_id(params[:subject_id])
    @subject = @project.create_valid_subject(params[:email], params[:site_id]) unless @subject
    @sheet = @project.sheets.where(design_id: @design.id).new(subject_id: @subject.id, authentication_token: Digest::SHA1.hexdigest(Time.zone.now.usec.to_s))
    if SheetTransaction.save_sheet!(@sheet, {}, variables_params, nil, request.remote_ip, 'public_sheet_create')
      if EMAILS_ENABLED
        UserMailer.survey_completed(@sheet).deliver_later
        UserMailer.survey_user_link(@sheet).deliver_later unless @subject.email.blank?
      end
      if @design.redirect_url.blank?
        redirect_to about_survey_path(survey: @design.slug, a: @sheet.authentication_token)
      else
        redirect_to @design.redirect_url
      end
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

  def set_public_design
    @design = Design.current.where(publicly_available: true).find_by_slug(params[:slug])
    @project = @design.project if @design
  end

  def redirect_without_design
    unless @design
      flash[:alert] = 'This survey no longer exists.'
      empty_response_or_root_path(about_survey_path)
    end
  end

  def set_sheet
    @sheet = @design.sheets.find_by_authentication_token(params[:sheet_authentication_token]) unless params[:sheet_authentication_token].blank?
  end

  def redirect_without_sheet
    unless @sheet
      flash[:alert] = 'This survey no longer exists.'
      empty_response_or_root_path(about_survey_path(survey: @design.slug))
    end
  end

  def redirect_on_locked_sheet
    if @sheet.locked?
      flash[:alert] = 'This survey has been locked.'
      empty_response_or_root_path(about_survey_path(survey: @design.slug))
    end
  end

  def variables_params
    (params[:variables].blank? ? {} : params.require(:variables).permit!)
  end
end
