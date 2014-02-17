class SubjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_viewable_project, only: [ :index, :show ]
  before_action :set_editable_project_or_editable_site, only: [ :new, :edit, :create, :update, :destroy ]
  before_action :redirect_without_project, only: [ :index, :show, :new, :edit, :create, :update, :destroy ]
  before_action :set_viewable_subject, only: [ :show ]
  before_action :set_editable_subject, only: [ :edit, :update, :destroy ]
  before_action :redirect_without_subject, only: [ :show, :edit, :update, :destroy ]

  # GET /subjects
  # GET /subjects.json
  def index
    @order = scrub_order(Subject, params[:order], 'subjects.subject_code')
    @statuses = params[:statuses] || ['valid']
    subject_scope = current_user.all_viewable_subjects.where(project_id: @project.id).where(status: @statuses).search(params[:search]).order(@order)
    subject_scope = subject_scope.where(site_id: params[:site_id]) unless params[:site_id].blank?
    subject_scope = Subject.without_design_event_schedule(subject_scope, @project, params[:without_design_id], params[:without_event_id], params[:without_schedule_id])

    @subjects = subject_scope.page(params[:page]).per( 40 )
  end

  # GET /subjects/1
  # GET /subjects/1.json
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
