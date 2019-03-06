# frozen_string_literal: true

# Allows project and site editors to view and modify subjects.
class SubjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_viewable_project_or_redirect, only: [
    :index, :show, :timeline, :comments, :files, :adverse_events,
    :ae_adverse_events, :events, :sheets, :event, :report, :search,
    :choose_site, :autocomplete, :designs_search, :events_search,
    :event_coverage, :medications
  ]
  before_action :find_editable_project_or_editable_site_or_redirect, only: [
    :new, :edit, :create, :update, :destroy, :choose_date,
    :data_entry, :send_url, :set_sheet_as_missing,
    :set_sheet_as_shareable, :new_data_entry, :choose_event,
    :launch_subject_event, :edit_event, :update_event, :destroy_event,
    :edit_medications, :add_medication, :review_medications,
    :review_medication, :review_medication_stop_date, :review_medication_something_changed,
    :review_medication_when_did_change_occur, :medication_added
  ]
  before_action :find_viewable_subject_or_redirect, only: [
    :show, :timeline, :comments, :files, :adverse_events, :ae_adverse_events,
    :events, :sheets, :event, :event_coverage, :medications
  ]
  before_action :find_editable_subject_or_redirect, only: [
    :edit, :update, :destroy, :choose_date, :data_entry, :send_url,
    :set_sheet_as_missing, :set_sheet_as_shareable, :new_data_entry,
    :choose_event, :launch_subject_event, :edit_event, :update_event,
    :destroy_event, :edit_medications, :add_medication, :review_medications,
    :review_medication, :review_medication_stop_date, :review_medication_something_changed,
    :review_medication_when_did_change_occur, :medication_added
  ]
  before_action :set_design, only: [
    :new_data_entry, :set_sheet_as_missing, :set_sheet_as_shareable
  ]
  before_action :check_for_randomizations, only: [:destroy]

  layout "layouts/full_page_sidebar_dark"

  # POST /projects/:project_id/subjects/1/event_coverage.js
  def event_coverage
    @subject_event = @subject.subject_events.find_by(id: params[:subject_event_id])
    if @subject_event
      @subject_event.check_coverage
      render "subject_events/coverage"
    else
      head :ok
    end
  end

  # # GET /projects/:project_id/subjects/1/data-entry
  # def data_entry
  # end

  # GET /projects/:project_id/subjects/1/data-entry/:design_id
  def new_data_entry
    # subject_event_id = params[:sheet][:subject_event_id] if params[:sheet] && params[:sheet].key?(:subject_event_id)
    # @sheet = @subject.sheets.new(project_id: @project.id, design_id: @design.id, subject_event_id: subject_event_id)
    @sheet = @subject.sheets
                     .where(
                       project_id: @project.id,
                       design_id: @design.id,
                       adverse_event_id: params[:adverse_event_id],
                       ae_adverse_event_id: params[:ae_adverse_event_id]
                     )
                     .new(sheet_params)
    render "sheets/new"
  end

  # POST /projects/:project_id/subjects/1/data-missing/:design_id/:subject_event_id.js
  def set_sheet_as_missing
    @sheet = @subject.sheets.new(
      project_id: @project.id, design_id: @design.id,
      subject_event_id: params[:subject_event_id], missing: true,
      user_id: current_user.id, last_user_id: current_user.id,
      last_edited_at: Time.zone.now
    )
    SheetTransaction.save_sheet!(@sheet, {}, {}, current_user, request.remote_ip, "sheet_create", skip_validation: true)
    render "sheets/subject_event"
  end

  # # GET /projects/:project_id/subjects/1/send-url
  # def send_url
  # end

  # POST /subjects/1/set_sheet_as_shareable
  def set_sheet_as_shareable
    @sheet = @subject.sheets.new(
      project_id: @project.id, design_id: @design.id,
      subject_event_id: params[:subject_event_id],
      last_user_id: current_user.id, last_edited_at: Time.zone.now
    )
    SheetTransaction.save_sheet!(
      @sheet, {}, {}, current_user, request.remote_ip, "sheet_create", skip_validation: true, skip_callbacks: true
    )
    @sheet.set_token
    redirect_to [@project, @sheet]
  end

  # # GET /projects/:project_id/subjects/1/choose-event
  # def choose_event
  # end

  # GET /projects/:project_id/subjects/1/events/:event_id/:subject_event_id/:event_date
  def event
    @event = @project.events.find_by_param(params[:event_id])
    if @event
      @subject_event = @subject.blinded_subject_events(current_user)
                               .where(event_id: @event.id)
                               .find_by(id: params[:subject_event_id])
    end
    redirect_to [@project, @subject] unless @subject_event
  end

  # GET /projects/:project_id/subjects/1/events/:event_id/:subject_event_id/:event_date/edit
  def edit_event
    @event = @project.events.find_by_param(params[:event_id])
    @subject_event = @subject.subject_events.where(event_id: @event.id).find_by(id: params[:subject_event_id]) if @event
    redirect_to [@project, @subject] unless @subject_event
  end

  # POST /projects/:project_id/subjects/1/events/:event_id/:subject_event_id
  def update_event
    @event = @project.events.find_by_param(params[:event_id])
    @subject_event = @subject.subject_events.where(event_id: @event.id).find_by(id: params[:subject_event_id]) if @event
    parse_date_if_key_present(:subject_event, :event_date)

    if @subject_event.update(subject_event_params)
      redirect_to event_project_subject_path(@project, @subject, event_id: @event,
                                                                 subject_event_id: @subject_event.id,
                                                                 event_date: @subject_event.event_date_to_param),
                  notice: "Event successfully updated."
    else
      render :edit_event
    end
  end

  # DELETE /projects/:project_id/subjects/1/events/:event_id/:subject_event_id/:event_date
  def destroy_event
    @event = @project.events.find_by_param(params[:event_id])
    @subject_event = @subject.subject_events.where(event_id: @event.id).find_by(id: params[:subject_event_id]) if @event
    if @subject_event
      @subject_event.unlink_sheets!(current_user, request.remote_ip)
      @subject_event.destroy
    end
    redirect_to [@project, @subject]
  end

  # # GET /projects/:project_id/subjects/1/events
  # def events
  # end

  # # GET /projects/:project_id/subjects/1/sheets
  # def sheets
  # end

  # # GET /projects/:project_id/subjects/1/timeline
  # def timeline
  # end

  # GET /projects/:project_id/subjects/1/comments
  def comments
    @comments = @subject.blinded_comments(current_user).includes(:user, :sheet)
                        .order(created_at: :desc).page(params[:page]).per(20)
  end

  # GET /projects/:project_id/subjects/1/files
  def files
    @uploaded_files = @subject.uploaded_files(current_user)
  end

  # POST /projects/:project_id/subjects/1/launch_subject_event
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
                    notice: "Event successfully created."
      else
        render :choose_date
      end
    else
      redirect_to [@project, @subject], alert: "Event #{params[:event_id]} not found on project." unless @event
    end
  end

  # Event chosen! Choose a design time.
  # GET /projects/:project_id/subjects/1/choose-date/:event_id
  def choose_date
    @event = @project.events.find_by_param(params[:event_id])
    if @event
      @subject_event = @subject.subject_events.where(event_id: @event.id).new
    else
      redirect_to [@project, @subject], alert: "Event #{params[:event_id]} not found on project."
    end
  end

  ## Find or create subject for the purpose of filling out a sheet for the subject.
  # GET /projects/:project_id/subjects/choose-site
  def choose_site
    redirect_to @project if params[:subject_code].blank?
    @subject = current_user.all_viewable_subjects.where(project_id: @project.id)
                           .where("LOWER(subjects.subject_code) = ?", params[:subject_code].to_s.downcase).first
    if !@project.site_or_project_editor?(current_user) && !@subject
      alert_text = params[:subject_code].blank? ? nil : "Subject <code>#{params[:subject_code]}</code> was not found."
      redirect_to @project, alert: alert_text
    elsif @subject
      redirect_to [@project, @subject]
    end
  end

  # GET /projects/:project_id/subjects/search
  def search
    @subjects = current_user.all_viewable_subjects.where(project_id: @project.id)
                            .search_any_order(params[:q]).order("subject_code").limit(10)
    if @subjects.count.zero?
      render json: [{ value: params[:q], subject_code: "Subject Not Found" }]
    else
      json_result = @subjects.pluck(:subject_code).collect do |subject_code|
        { value: subject_code, subject_code: subject_code }
      end
      render json: json_result
    end
  end

  # GET /projects/:project_id/subjects/autocomplete
  def autocomplete
    subject_scope = current_user.all_viewable_subjects
                                .where(project_id: @project.id)
                                .where("subject_code ILIKE (?)", "#{params[:q]}%")
                                .order(:subject_code).limit(10)
    terms = ["adverse-events", "designs", "events", "has", "is", "no", "not"]
    additional_terms = terms.reject { |term| (/^#{params[:q]}/ =~ term).nil? }
    render json: additional_terms + subject_scope.pluck(:subject_code)
  end

  # GET /projects/:project_id/subjects/designs_search.json
  def designs_search
    scope = @project.designs
                    .where("name ILIKE (?) or slug ILIKE (?) or id = ?", "#{params[:q]}%", "#{params[:q]}%", params[:q].to_i)
                    .order(:slug, :name).limit(10)
    render json: scope.collect { |d| { value: d.to_param, name: d.name } }
  end

  # GET /projects/:project_id/subjects/events_search.json
  def events_search
    scope = @project.events
                    .where("name ILIKE (?) or slug ILIKE (?) or id = ?", "#{params[:q]}%", "#{params[:q]}%", params[:q].to_i)
                    .order(:slug, :name).limit(10)
    render json: scope.collect { |e| { value: e.to_param, name: e.name } }
  end

  # GET /subjects
  def index
    scope = current_user.all_viewable_subjects.where(project_id: @project.id)
    scope = scope_includes(scope)
    scope = scope_search_filter(scope, params[:search])
    scope = scope_filter(scope)
    @subjects = scope_order(scope).page(params[:page]).per(20)
    if params[:search].present? && scope.count == 1 && scope.first && scope.first.subject_code == params[:search]
      redirect_to [@project, scope.first]
    end
  end

  # # GET /subjects/1
  # def show
  # end

  # GET /subjects/new
  def new
    @subject = current_user.subjects.where(project_id: @project.id).new(subject_params)
  end

  # # GET /subjects/1/edit
  # def edit
  # end

  # POST /subjects
  def create
    @subject = current_user.subjects.where(project_id: @project.id).new(subject_params)
    if @subject.save
      redirect_to [@project, @subject], notice: "Subject was successfully created."
    else
      render :new
    end
  end

  # PATCH /subjects/1
  def update
    if @subject.update(subject_params)
      redirect_to [@project, @subject], notice: "Subject was successfully updated."
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
    super(:id)
  end

  def find_editable_subject_or_redirect
    super(:id)
  end

  def check_for_randomizations
    return unless @subject.randomizations.count > 0
    redirect_to [@project, @subject],
                alert: "You must undo this subject's randomizations in order to delete the subject."
  end

  def set_design
    @design = current_user.all_viewable_designs.where(project_id: @project.id).find_by_param(params[:design_id])
    empty_response_or_root_path(data_entry_project_subject_path(@project, @subject)) unless @design
  end

  def subject_params
    params[:subject] ||= { blank: "1" }
    clean_site_id
    params.require(:subject).permit(:subject_code, :site_id)
  end

  # Sets site id to nil if it's not part of users editable sites.
  def clean_site_id
    params[:subject][:site_id] = \
      if current_user.all_editable_sites.pluck(:id).include?(params[:site_id].to_i)
        params[:site_id].to_i
      end
  end

  def sheet_params
    params[:sheet] ||= { blank: "1" }
    params.require(:sheet).permit(:subject_event_id) # :adverse_event_id, :ae_adverse_event_id
  end

  def subject_event_params
    params[:subject_event] ||= { blank: "1" }
    params.require(:subject_event).permit(:event_date)
  end

  def scope_includes(scope)
    scope.includes(:site)
  end

  def scope_filter(scope)
    [:site_id].each do |key|
      scope = scope.where(key => params[key]) if params[key].present?
    end
    scope
  end

  def scope_search_filter(scope, search)
    @tokens = Search.pull_tokens(search)
    @tokens.reject { |t| t.key == "search" }.each do |token|
      scope = SearchSubject.subjects(@project, current_user, scope, token)
    end
    terms = @tokens.select { |t| t.key == "search" }.collect(&:value)
    scope.search_any_order(terms.join(" "))
  end

  def scope_order(scope)
    @order = scrub_order(Subject, params[:order], "subjects.subject_code")
    scope.order(@order)
  end
end
