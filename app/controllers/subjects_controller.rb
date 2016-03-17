# frozen_string_literal: true

# Allows project and site editors to view and modify subjects.
class SubjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_viewable_project_or_redirect, only: [
    :index, :show, :timeline, :comments, :settings, :files, :adverse_events,
    :events, :sheets, :event, :report, :search, :choose_site
  ]
  before_action :find_editable_project_or_editable_site_or_redirect, only: [
    :new, :edit, :create, :update, :destroy, :choose_date,
    :choose_an_event_for_subject, :data_entry, :send_url, :set_sheet_as_missing,
    :set_sheet_as_shareable, :new_data_entry, :choose_event,
    :launch_subject_event, :edit_event, :update_event, :destroy_event
  ]
  before_action :find_viewable_subject_or_redirect, only: [
    :show, :timeline, :comments, :settings, :files, :adverse_events, :events,
    :sheets, :event
  ]
  before_action :find_editable_subject_or_redirect, only: [
    :edit, :update, :destroy, :choose_date, :choose_an_event_for_subject,
    :data_entry, :send_url, :set_sheet_as_missing, :set_sheet_as_shareable,
    :new_data_entry, :choose_event, :launch_subject_event, :edit_event,
    :update_event, :destroy_event
  ]
  before_action :set_design, only: [
    :new_data_entry, :set_sheet_as_missing, :set_sheet_as_shareable
  ]
  before_action :check_for_randomizations, only: [:destroy]

  def data_entry
  end

  def new_data_entry
    # subject_event_id = params[:sheet][:subject_event_id] if params[:sheet] && params[:sheet].key?(:subject_event_id)
    # @sheet = @subject.sheets.new(project_id: @project.id, design_id: @design.id, subject_event_id: subject_event_id)
    @sheet = @subject.sheets
                     .where(project_id: @project.id, design_id: @design.id, adverse_event_id: params[:adverse_event_id])
                     .new(sheet_params)
    render 'sheets/new'
  end

  # POST /subjects/1/data-missing/:design_id/:subject_event_id.js
  def set_sheet_as_missing
    @sheet = @subject.sheets.new(
      project_id: @project.id, design_id: @design.id,
      subject_event_id: params[:subject_event_id], missing: true
    )
    SheetTransaction.save_sheet!(@sheet, {}, {}, current_user, request.remote_ip, 'sheet_create')
  end

  # GET /subjects/1/send-url
  def send_url
  end

  # POST /subjects/1/set_sheet_as_shareable
  def set_sheet_as_shareable
    @sheet = @subject.sheets
                     .new(project_id: @project.id, design_id: @design.id, subject_event_id: params[:subject_event_id])
    SheetTransaction.save_sheet!(@sheet, {}, {}, current_user, request.remote_ip, 'sheet_create')
    @sheet.set_token
    redirect_to [@project, @sheet]
  end

  def choose_event
  end

  def event
    @event = @project.events.find_by_param(params[:event_id])
    @subject_event = @subject.blinded_subject_events(current_user)
                             .where(event_id: @event.id).find_by_id(params[:subject_event_id]) if @event
    redirect_to [@project, @subject] unless @subject_event
  end

  def edit_event
    @event = @project.events.find_by_param(params[:event_id])
    @subject_event = @subject.subject_events.where(event_id: @event.id).find_by_id(params[:subject_event_id]) if @event
    redirect_to [@project, @subject] unless @subject_event
  end

  def update_event
    @event = @project.events.find_by_param(params[:event_id])
    @subject_event = @subject.subject_events.where(event_id: @event.id).find_by_id(params[:subject_event_id]) if @event
    parse_date_if_key_present(:subject_event, :event_date)

    if @subject_event.update(subject_event_params)
      redirect_to event_project_subject_path(@project, @subject, event_id: @event,
                                                                 subject_event_id: @subject_event.id,
                                                                 event_date: @subject_event.event_date_to_param),
                  notice: 'Subject event updated successfully.'
    else
      render :edit_event
    end
  end

  def destroy_event
    @event = @project.events.find_by_param(params[:event_id])
    @subject_event = @subject.subject_events.where(event_id: @event.id).find_by_id(params[:subject_event_id]) if @event
    if @subject_event
      @subject_event.unlink_sheets!(current_user, request.remote_ip)
      @subject_event.destroy
    end
    redirect_to [@project, @subject]
  end

  def events
  end

  def sheets
  end

  def timeline
  end

  def comments
    @comments = @subject.blinded_comments(current_user).includes(:user, :sheet)
                        .order(created_at: :desc).page(params[:page]).per(20)
  end

  def files
    @uploaded_files = @subject.uploaded_files(current_user).includes(:variable, :sheet).page(params[:page]).per(40)
  end

  def launch_subject_event
    @event = @project.events.find_by_param(params[:event_id])
    if @event
      parse_date_if_key_present(:subject_event, :event_date)

      @subject_event = @subject.subject_events
                               .where(event_id: @event.id, user_id: current_user.id)
                               .new(subject_event_params)

      if @subject_event.save
        redirect_to event_project_subject_path(@project, @subject, event_id: @event,
                                                                   subject_event_id: @subject_event.id,
                                                                   event_date: @subject_event.event_date_to_param),
                    notice: 'Subject event created successfully.'
      else
        render :choose_date
      end
    else
      redirect_to [@project, @subject], alert: "Event #{params[:event_id]} not found on project." unless @event
    end
  end

  # Event chosen! Choose a design time.
  def choose_date
    @event = @project.events.find_by_param(params[:event_id])
    if @event
      @subject_event = @subject.subject_events.where(event_id: @event.id).new
    else
      redirect_to [@project, @subject], alert: "Event #{params[:event_id]} not found on project."
    end
  end

  # So many events, so little time
  def choose_an_event_for_subject
  end

  ## Find or create subject for the purpose of filling out a sheet for the subject.
  def choose_site
    redirect_to @project if params[:subject_code].blank?
    @subject = current_user.all_viewable_subjects.where(project_id: @project.id)
                           .where('LOWER(subjects.subject_code) = ?', params[:subject_code].to_s.downcase).first
    if !@project.site_or_project_editor?(current_user) && !@subject
      alert_text = params[:subject_code].blank? ? nil : "Subject <code>#{params[:subject_code]}</code> was not found."
      redirect_to @project, alert: alert_text
    elsif @subject
      redirect_to [@project, @subject]
    end
  end

  def search
    @subjects = current_user.all_viewable_subjects.where(project_id: @project.id)
                            .search(params[:q]).order('subject_code').limit(10)

    if @subjects.count == 0
      if @project.site_or_project_editor? current_user
        render json: [{ value: params[:q], subject_code: params[:q], status_class: 'warning', status: 'NEW' }]
      else
        render json: []
      end
    else
      json_result = @subjects.collect do |s|
        { value: s.subject_code, subject_code: s.subject_code, status_class: 'success', status: '' }
      end
      render json: json_result
    end
  end

  # GET /subjects
  def index
    @order = scrub_order(Subject, params[:order], 'subjects.subject_code')
    subject_scope = current_user.all_viewable_subjects.where(project_id: @project.id)
                                .search(params[:search]).order(@order)
    subject_scope = subject_scope.where(site_id: params[:site_id]) unless params[:site_id].blank?

    if params[:on_event_design_id].present? && params[:event_id].present?
      subject_scope = subject_scope.with_entered_design_on_event(params[:on_event_design_id], params[:event_id])
    elsif params[:not_on_event_design_id].present? && params[:event_id].present?
      subject_scope = subject_scope.with_unentered_design_on_event(params[:not_on_event_design_id], params[:event_id])
    elsif params[:event_id].present?
      subject_scope = subject_scope.with_event(params[:event_id])
    elsif params[:without_event_id].present?
      subject_scope = subject_scope.without_event(params[:without_event_id])
    else
      subject_scope = subject_scope.without_design(params[:without_design_id]) if params[:without_design_id].present?
      subject_scope = subject_scope.with_design(params[:design_id]) if params[:design_id].present?
    end

    @subjects = subject_scope.page(params[:page]).per(40)
    @events = @project.events.where(archived: false).order(:position)
  end

  # GET /subjects/1
  def show
  end

  # GET /subjects/new
  def new
    @subject = current_user.subjects.new(subject_params)
  end

  # GET /subjects/1/edit
  def edit
  end

  # POST /subjects
  def create
    @subject = current_user.subjects.new(subject_params)
    if @subject.save
      redirect_to [@project, @subject], notice: 'Subject was successfully created.'
    else
      render :new
    end
  end

  # PATCH /subjects/1
  def update
    if @subject.update(subject_params)
      redirect_to [@project, @subject], notice: 'Subject was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /subjects/1
  # DELETE /subjects/1.js
  def destroy
    @subject.destroy

    respond_to do |format|
      format.html { redirect_to project_subjects_path(@project) }
      format.js
    end
  end

  private

  def find_viewable_subject_or_redirect
    @subject = current_user.all_viewable_subjects.find_by_id(params[:id])
    redirect_without_subject
  end

  def find_editable_subject_or_redirect
    @subject = current_user.all_subjects.find_by_id(params[:id])
    redirect_without_subject
  end

  def redirect_without_subject
    empty_response_or_root_path(project_subjects_path(@project)) unless @subject
  end

  def check_for_randomizations
    return unless @subject.randomizations.count > 0
    redirect_to settings_project_subject_path(@project, @subject),
                alert: "You must undo this subject\'s randomizations in order to delete the subject."
  end

  def set_design
    @design = current_user.all_viewable_designs.where(project_id: @project.id).find_by_param params[:design_id]
    empty_response_or_root_path(data_entry_project_subject_path(@project, @subject)) unless @design
  end

  def subject_params
    params[:subject] ||= { blank: '1' }
    clean_subject_code
    clean_site_id
    params[:subject][:project_id] = @project.id
    params.require(:subject).permit(:project_id, :subject_code, :site_id)
  end

  def clean_subject_code
    return if params[:subject][:subject_code].blank?
    params[:subject][:subject_code].to_s.strip!
  end

  # Sets site id to nil if it's not part of users editable sites.
  def clean_site_id
    params[:subject][:site_id] = if current_user.all_editable_sites.pluck(:id).include?(params[:site_id].to_i)
                                   params[:site_id].to_i
                                 end
  end

  def sheet_params
    params[:sheet] ||= { blank: '1' }
    params.require(:sheet).permit(:subject_event_id) # :adverse_event_id
  end

  def subject_event_params
    params[:subject_event] ||= { blank: '1' }
    params.require(:subject_event).permit(:event_date)
  end
end
