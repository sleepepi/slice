class SubjectsController < ApplicationController
  before_filter :authenticate_user!

  # GET /subjects
  # GET /subjects.json
  def index
    subject_scope = current_user.all_viewable_subjects

    project = Project.find_by_id(params[:project_id])
    params[:site_id] = nil if project and not project.sites.pluck(:id).include?(params[:site_id].to_i)
    params[:design_id] = nil if project and not project.designs.pluck(:id).include?(params[:design_id].to_i)

    ['project', 'site'].each do |filter|
      subject_scope = subject_scope.send("with_#{filter}", params["#{filter}_id".to_sym]) unless params["#{filter}_id".to_sym].blank?
    end

    subject_scope = subject_scope.without_design(params[:without_design_id]) unless params[:without_design_id].blank?

    # inverse_subject_scope = subject_scope

    # (params[:design_ids] || []).each do |design_id|
    #   inverse_subject_scope = inverse_subject_scope.with_design(design_id)
    # end
    # Inverse Subject Scope contains all subjects that have all the specified designs

    @search_terms = params[:search].to_s.gsub(/[^0-9a-zA-Z]/, ' ').split(' ')
    @search_terms.each{|search_term| subject_scope = subject_scope.search(search_term) }

    @order = Subject.column_names.collect{|column_name| "subjects.#{column_name}"}.include?(params[:order].to_s.split(' ').first) ? params[:order] : "subjects.subject_code"
    subject_scope = subject_scope.order(@order)
    @subject_count = subject_scope.count
    @subjects = subject_scope.page(params[:page]).per( 20 )

    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.json { render json: @subjects }
    end
  end

  # GET /subjects/1
  # GET /subjects/1.json
  def show
    @subject = current_user.all_viewable_subjects.find_by_id(params[:id])

    respond_to do |format|
      if @subject
        format.html # show.html.erb
        format.json { render json: @subject }
      else
        format.html { redirect_to subjects_path }
        format.json { head :no_content }
      end
    end
  end

  # GET /subjects/new
  # GET /subjects/new.json
  def new
    @subject = current_user.subjects.new(post_params)

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @subject }
    end
  end

  # GET /subjects/1/edit
  def edit
    @subject = current_user.all_subjects.find_by_id(params[:id])
    redirect_to subjects_path unless @subject
  end

  # POST /subjects
  # POST /subjects.json
  def create
    @subject = current_user.subjects.new(post_params)

    respond_to do |format|
      if @subject.save
        format.html { redirect_to @subject, notice: 'Subject was successfully created.' }
        format.json { render json: @subject, status: :created, location: @subject }
      else
        format.html { render action: "new" }
        format.json { render json: @subject.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /subjects/1
  # PUT /subjects/1.json
  def update
    @subject = current_user.all_subjects.find_by_id(params[:id])

    respond_to do |format|
      if @subject
        if @subject.update_attributes(post_params)
          format.html { redirect_to @subject, notice: 'Subject was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @subject.errors, status: :unprocessable_entity }
        end
      else
        format.html { redirect_to subjects_path }
        format.json { head :no_content }
      end
    end
  end

  # DELETE /subjects/1
  # DELETE /subjects/1.json
  def destroy
    @subject = current_user.all_subjects.find_by_id(params[:id])
    @subject.destroy if @subject

    respond_to do |format|
      format.html { redirect_to subjects_path }
      format.json { head :no_content }
    end
  end

  private

  def post_params
    params[:subject] ||= {}

    params[:subject][:site_id] = params[:site_id]

    params[:subject][:project_id] = nil unless current_user.all_viewable_projects.pluck(:id).include?(params[:subject][:project_id].to_i)

    params[:subject].slice(
      :project_id, :subject_code, :site_id
    )
  end
end
