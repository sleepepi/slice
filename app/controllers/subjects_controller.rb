# frozen_string_literal: true

class SubjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_viewable_project,                  only: [:index, :show, :timeline, :comments, :settings, :files, :adverse_events, :events, :sheets, :event, :report, :search, :choose_site]
  before_action :set_editable_project_or_editable_site, only: [:new, :edit, :create, :update, :destroy, :choose_date, :choose_an_event_for_subject, :data_entry, :new_data_entry, :choose_event, :launch_subject_event, :edit_event, :update_event, :destroy_event]
  before_action :redirect_without_project,              only: [:index, :show, :timeline, :comments, :settings, :files, :adverse_events, :events, :sheets, :event, :report, :search, :choose_site, :new, :edit, :create, :update, :destroy, :choose_date, :choose_an_event_for_subject, :data_entry, :new_data_entry, :choose_event, :launch_subject_event, :edit_event, :update_event, :destroy_event]
  before_action :set_viewable_subject,                  only: [:show, :timeline, :comments, :settings, :files, :adverse_events, :events, :sheets, :event]
  before_action :set_editable_subject,                  only: [:edit, :update, :destroy, :choose_date, :choose_an_event_for_subject, :data_entry, :new_data_entry, :choose_event, :launch_subject_event, :edit_event, :update_event, :destroy_event]
  before_action :set_design,                            only: [:new_data_entry]

  def data_entry
  end

  def new_data_entry
    # subject_event_id = params[:sheet][:subject_event_id] if params[:sheet] && params[:sheet].key?(:subject_event_id)
    # @sheet = @subject.sheets.new(project_id: @project.id, design_id: @design.id, subject_event_id: subject_event_id)
    @sheet = @subject.sheets.where(project_id: @project.id, design_id: @design.id, adverse_event_id: params[:adverse_event_id]).new(sheet_params)
    render 'sheets/new'
  end

  def choose_event
  end

  def event
    @event = @project.events.find_by_param(params[:event_id])
    @subject_event = @subject.subject_events.where(event_id: @event.id).find_by_id(params[:subject_event_id]) if @event
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

    month = parse_integer(params[:new_event_date] ? params[:new_event_date][:month] : nil)
    day = parse_integer(params[:new_event_date] ? params[:new_event_date][:day] : nil)
    year = parse_integer(params[:new_event_date] ? params[:new_event_date][:year] : nil)
    date = parse_date("#{month}/#{day}/#{year}")

    if @subject_event and date
      @subject_event.update event_date: date
      redirect_to event_project_subject_path(@project, @subject, event_id: @event, subject_event_id: @subject_event.id, event_date: @subject_event.event_date_to_param), notice: 'Subject event updated successfully.'
    elsif @subject_event and date == nil
      redirect_to edit_event_project_subject_path(@project, @subject, event_id: @event, subject_event_id: @subject_event.id, event_date: @subject_event.event_date_to_param, new_event_date: { month: month, day: day, year: year }), alert: 'Please enter a valid date.'
    else
      redirect_to [@project, @subject], alert: "#{date.inspect}"
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
    @comments = @subject.blinded_comments(current_user).includes(:user, :sheet).order(created_at: :desc).page(params[:page]).per(20)
  end

  def files
    @uploaded_files = @subject.uploaded_files(current_user).includes(:variable, :sheet).page(params[:page]).per(40)
  end

  def launch_subject_event
    @event = @project.events.find_by_param(params[:event_id])
    if @event
      month = parse_integer(params[:event_date] ? params[:event_date][:month] : nil)
      day = parse_integer(params[:event_date] ? params[:event_date][:day] : nil)
      year = parse_integer(params[:event_date] ? params[:event_date][:year] : nil)
      date = parse_date("#{month}/#{day}/#{year}")

      if date and @subject_event = @subject.subject_events.create(event_id: @event.id, event_date: date, user_id: current_user.id)
        redirect_to event_project_subject_path(@project, @subject, event_id: @event, subject_event_id: @subject_event.id, event_date: @subject_event.event_date_to_param), notice: 'Subject event created successfully.'
      else
        redirect_to choose_date_project_subject_path(@project, @subject, event_id: @event.to_param, event_date: { month: month, day: day, year: year }), alert: 'Please enter a valid date.'
      end
    else
      redirect_to [@project, @subject], alert: "Event #{params[:event_id]} not found on project." unless @event
    end
  end

  # Event chosen! Choose a design time.
  def choose_date
    @event = @project.events.find_by_param(params[:event_id])
    redirect_to [@project, @subject], alert: "Event #{params[:event_id]} not found on project." unless @event
  end

  # So many events, so little time
  def choose_an_event_for_subject
  end

  ## Find or create subject for the purpose of filling out a sheet for the subject.
  def choose_site
    @subject = current_user.all_viewable_subjects.where(project_id: @project.id).where("LOWER(subjects.subject_code) = ?", params[:subject_code].to_s.downcase).first
    if !@project.site_or_project_editor?(current_user) && !@subject
      alert_text = params[:subject_code].blank? ? nil : "Subject <code>#{params[:subject_code]}</code> was not found."
      redirect_to @project, alert: alert_text
    else
      redirect_to [@project, @subject] if @subject
    end
  end

  def search
    @subjects = current_user.all_viewable_subjects.where(project_id: @project.id).search(params[:q]).order('subject_code').limit(10)

    if @subjects.count == 0
      if @project.site_or_project_editor? current_user
        render json: [{ value: params[:q], subject_code: params[:q], status_class: 'warning', status: 'NEW' }]
      else
        render json: []
      end
    else
      render json: @subjects.collect{ |s| { value: s.subject_code, subject_code: s.subject_code, status_class: (s.status == 'valid' ? 'success' : 'info'), status: s.status.first  } }
    end
  end

  # GET /subjects
  # GET /subjects.json
  def index
    @order = scrub_order(Subject, params[:order], 'subjects.subject_code')
    @statuses = params[:statuses] || ['valid']
    subject_scope = current_user.all_viewable_subjects.where(project_id: @project.id).where(status: @statuses).search(params[:search]).order(@order)
    subject_scope = subject_scope.where(site_id: params[:site_id]) unless params[:site_id].blank?

    if params[:on_event_design_id].present? and params[:event_id].present?
      subject_scope = subject_scope.with_entered_design_on_event(params[:on_event_design_id], params[:event_id])
    elsif params[:not_on_event_design_id].present? and params[:event_id].present?
      subject_scope = subject_scope.with_unentered_design_on_event(params[:not_on_event_design_id], params[:event_id])
    elsif params[:event_id].present?
      subject_scope = subject_scope.with_event(params[:event_id])
    elsif params[:without_event_id].present?
      subject_scope = subject_scope.without_event(params[:without_event_id])
    else
      subject_scope = subject_scope.without_design(params[:without_design_id]) if params[:without_design_id].present?
      subject_scope = subject_scope.with_design(params[:design_id]) if params[:design_id].present?
    end

    @subjects = subject_scope.page(params[:page]).per( 40 )
    @events = @project.events.where(archived: false).order(:position)
  end

  # GET /subjects/1
  # GET /subjects/1.json
  def show
    # render layout: 'layouts/application_custom_full'
  end

  # GET /subjects/new
  def new
    @subject = current_user.subjects.new(subject_params)
  end

  # GET /subjects/1/edit
  def edit
  end

  # POST /subjects
  # POST /subjects.json
  def create
    @subject = current_user.subjects.new(subject_params)

    respond_to do |format|
      if @subject.save
        format.html { redirect_to [@project, @subject], notice: 'Subject was successfully created.' }
        format.json { render action: 'show', status: :created, location: @subject }
      else
        format.html { render action: 'new' }
        format.json { render json: @subject.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /subjects/1
  # PUT /subjects/1.json
  def update
    respond_to do |format|
      if @subject.update(subject_params)
        format.html { redirect_to [@project, @subject], notice: 'Subject was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @subject.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /subjects/1
  # DELETE /subjects/1.json
  def destroy
    @subject.destroy

    respond_to do |format|
      format.html { redirect_to project_subjects_path(@project) }
      format.js
      format.json { head :no_content }
    end
  end

  private

  def set_viewable_subject
    @subject = current_user.all_viewable_subjects.find_by_id(params[:id])
    redirect_without_subject
  end

  def set_editable_subject
    @subject = current_user.all_subjects.find_by_id(params[:id])
    redirect_without_subject
  end

  def redirect_without_subject
    empty_response_or_root_path(project_subjects_path(@project)) unless @subject
  end

  def set_design
    @design = current_user.all_viewable_designs.where(project_id: @project.id).find_by_param params[:design_id]
    empty_response_or_root_path(data_entry_project_subject_path(@project, @subject)) unless @design
  end

  def subject_params
    params[:subject] ||= {}
    params[:subject][:subject_code] = params[:subject][:subject_code].strip unless params[:subject][:subject_code].blank?
    params[:subject][:site_id] = (current_user.all_editable_sites.pluck(:id).include?(params[:site_id].to_i) ? params[:site_id].to_i : nil)
    params[:subject][:project_id] = @project.id
    params.require(:subject).permit(
      :project_id, :subject_code, :site_id, :acrostic, :email, :status
    )
  end

  def sheet_params
    params[:sheet] ||= { blank: '1' }
    params.require(:sheet).permit(:subject_event_id) # :adverse_event_id
  end
end
