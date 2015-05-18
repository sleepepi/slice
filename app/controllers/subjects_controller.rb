class SubjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_viewable_project, only: [ :index, :show, :timeline, :comments, :settings, :files, :events, :sheets, :event, :report ]
  before_action :set_editable_project_or_editable_site, only: [ :new, :edit, :create, :update, :destroy, :search, :choose_site, :choose_date, :choose_an_event_for_subject, :data_entry, :choose_event, :launch_subject_event, :edit_event, :update_event ]
  before_action :redirect_without_project, only: [ :index, :show, :timeline, :comments, :settings, :files, :sheets, :event, :report, :new, :edit, :create, :update, :destroy, :search, :choose_site, :choose_date, :choose_an_event_for_subject, :data_entry, :choose_event, :events, :launch_subject_event, :edit_event, :update_event ]
  before_action :set_viewable_subject, only: [ :show, :timeline, :comments, :settings, :files, :sheets, :event ]
  before_action :set_editable_subject, only: [ :edit, :update, :destroy, :choose_date, :choose_an_event_for_subject, :data_entry, :choose_event, :events, :launch_subject_event, :edit_event, :update_event ]
  before_action :redirect_without_subject, only: [ :show, :timeline, :comments, :settings, :files, :sheets, :event, :edit, :update, :destroy, :choose_date, :choose_an_event_for_subject, :data_entry, :choose_event, :events, :launch_subject_event, :edit_event, :update_event ]

  def data_entry
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
    if @subject_event and date = parse_date(params[:new_event_date], nil)
      @subject_event.update event_date: date
      redirect_to event_project_subject_path(@project, @subject, event_id: @event, subject_event_id: @subject_event.id, event_date: @subject_event.event_date_to_param), notice: 'Subject event updated successfully.'
    elsif @subject_event and date == nil
      redirect_to edit_event_project_subject_path(@project, @subject, event_id: @event, subject_event_id: @subject_event.id, event_date: @subject_event.event_date_to_param), alert: 'Please enter a valid date.'
    else
      redirect_to [@project, @subject], alert: "#{params[:new_event_date].inspect}"
    end

  end

  def events
  end

  def sheets
  end

  def timeline
  end

  def comments
    @comments = @subject.comments.includes(:user, :sheet).order(created_at: :desc).page(params[:page]).per(20)
  end

  def files
    @uploaded_files = @subject.uploaded_files.includes(:variable, :sheet).page(params[:page]).per(40)
  end


  def launch_subject_event
    @event = @project.events.find_by_param(params[:event_id])
    if @event

      if date = parse_date(params[:event_date], nil) and @subject_event = @subject.subject_events.create(event_id: @event.id, event_date: date)
        redirect_to event_project_subject_path(@project, @subject, event_id: @event, subject_event_id: @subject_event.id, event_date: @subject_event.event_date_to_param), notice: 'Subject event created successfully.'
      else
        redirect_to choose_date_project_subject_path(@project, @subject, event_id: @event.to_param), alert: 'Please enter a valid date.'
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
    redirect_to [@project, @subject] if @subject
  end

  def search
    @subjects = current_user.all_viewable_subjects.where(project_id: @project.id).search(params[:q]).order('subject_code').limit(10)

    if @subjects.count == 0
      render json: [{ value: params[:q], subject_code: params[:q], status_class: 'warning', status: 'NEW' }]
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
    subject_scope = Subject.without_design_event_schedule(subject_scope, @project, params[:without_design_id], params[:without_event_id], params[:without_schedule_id])

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
    end

    def set_editable_subject
      @subject = current_user.all_subjects.find_by_id(params[:id])
    end

    def redirect_without_subject
      empty_response_or_root_path(project_subjects_path(@project)) unless @subject
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

end
