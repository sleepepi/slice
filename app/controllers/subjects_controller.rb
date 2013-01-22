class SubjectsController < ApplicationController
  before_filter :authenticate_user!

  # GET /subjects
  # GET /subjects.json
  def index
    @project = current_user.all_viewable_and_site_projects.find_by_id(params[:project_id])

    if @project
      current_user.pagination_set!('subjects', params[:subjects_per_page].to_i) if params[:subjects_per_page].to_i > 0
      subject_scope = current_user.all_viewable_subjects

      @project = Project.find_by_id(params[:project_id])
      params[:site_id] = nil if @project and not @project.sites.pluck(:id).include?(params[:site_id].to_i)
      params[:design_id] = nil if @project and not @project.designs.pluck(:id).include?(params[:design_id].to_i)

      ['project', 'site'].each do |filter|
        subject_scope = subject_scope.send("with_#{filter}", params["#{filter}_id".to_sym]) unless params["#{filter}_id".to_sym].blank?
      end

      subject_scope = subject_scope.without_design(params[:without_design_id]) unless params[:without_design_id].blank?

      @statuses = params[:statuses] || ['valid', 'pending', 'test']
      subject_scope = subject_scope.where(status: @statuses)

      @search_terms = params[:search].to_s.gsub(/[^0-9a-zA-Z]/, ' ').split(' ')
      @search_terms.each{|search_term| subject_scope = subject_scope.search(search_term) }

      @order = scrub_order(Subject, params[:order], 'subjects.subject_code')
      subject_scope = subject_scope.order(@order)

      @subject_count = subject_scope.count
      @subjects = subject_scope.page(params[:page]).per( current_user.pagination_count('subjects') )
    end

    respond_to do |format|
      if @project
        format.html # index.html.erb
        format.js
        format.json { render json: @subjects }
      else
        format.html { redirect_to root_path }
        format.js { render nothing: true }
        format.json { head :no_content }
      end
    end
  end

  # GET /subjects/1
  # GET /subjects/1.json
  def show
    @project = current_user.all_viewable_and_site_projects.find_by_id(params[:project_id])
    @subject = current_user.all_viewable_subjects.find_by_id(params[:id])

    respond_to do |format|
      if @project and @subject
        format.html # show.html.erb
        format.json { render json: @subject }
      elsif @project
        format.html { redirect_to project_subjects_path(@project), alert: 'You do not have sufficient privileges to view this subject.' }
        format.json { head :no_content }
      else
        format.html { redirect_to root_path }
        format.json { head :no_content }
      end
    end
  end

  # GET /subjects/new
  # GET /subjects/new.json
  def new
    @project = current_user.all_viewable_projects.find_by_id(params[:project_id])
    @subject = current_user.subjects.new(post_params)

    respond_to do |format|
      if @project and @subject
        format.html # new.html.erb
        format.json { render json: @subject }
      else
        format.html { redirect_to root_path }
        format.json { head :no_content }
      end
    end
  end

  # GET /subjects/1/edit
  def edit
    @project = current_user.all_viewable_projects.find_by_id(params[:project_id])
    @subject = current_user.all_subjects.find_by_id(params[:id])

    if @project and @subject
      # edit.html.erb
    elsif @project
      redirect_to project_subjects_path(@project)
    else
      redirect_to root_path
    end
  end

  # POST /subjects
  # POST /subjects.json
  def create
    @project = current_user.all_viewable_projects.find_by_id(params[:project_id])
    @subject = current_user.subjects.new(post_params)

    respond_to do |format|
      if @project
        if @subject.save
          format.html { redirect_to [@project, @subject], notice: 'Subject was successfully created.' }
          format.json { render json: @subject, status: :created, location: @subject }
        else
          format.html { render action: "new" }
          format.json { render json: @subject.errors, status: :unprocessable_entity }
        end
      else
        format.html { redirect_to root_path }
        format.json { head :no_content }
      end
    end
  end

  # PUT /subjects/1
  # PUT /subjects/1.json
  def update
    @project = current_user.all_viewable_projects.find_by_id(params[:project_id])
    @subject = current_user.all_subjects.find_by_id(params[:id])

    respond_to do |format|
      if @project and @subject
        if @subject.update_attributes(post_params)
          format.html { redirect_to [@project, @subject], notice: 'Subject was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @subject.errors, status: :unprocessable_entity }
        end
      elsif @project
        format.html { redirect_to project_subjects_path(@project) }
        format.json { head :no_content }
      else
        format.html { redirect_to root_path }
        format.json { head :no_content }
      end
    end
  end

  # DELETE /subjects/1
  # DELETE /subjects/1.json
  def destroy
    @project = current_user.all_viewable_projects.find_by_id(params[:project_id])
    @subject = current_user.all_subjects.find_by_id(params[:id])
    @subject.destroy if @project and @subject

    respond_to do |format|
      if @project
        format.html { redirect_to project_subjects_path(@project) }
        format.js { render 'destroy' }
        format.json { head :no_content }
      else
        format.html { redirect_to root_path }
        format.js { render nothing: true }
        format.json { head :no_content }
      end
    end
  end

  private

  def post_params
    params[:subject] ||= {}

    params[:subject][:site_id] = params[:site_id]

    if current_user.all_viewable_projects.pluck(:id).include?(params[:project_id].to_i)
      params[:subject][:project_id] = params[:project_id]
    else
      params[:subject][:project_id] = nil
    end

    params[:subject].slice(
      :project_id, :subject_code, :site_id, :acrostic, :email, :status
    )
  end
end
