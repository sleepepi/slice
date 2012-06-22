class ProjectsController < ApplicationController
  before_filter :authenticate_user!

  # GET /projects
  # GET /projects.json
  def index
    project_scope = current_user.all_viewable_projects

    @search_terms = params[:search].to_s.gsub(/[^0-9a-zA-Z]/, ' ').split(' ')
    @search_terms.each{|search_term| project_scope = project_scope.search(search_term) }

    @order = Project.column_names.collect{|column_name| "projects.#{column_name}"}.include?(params[:order].to_s.split(' ').first) ? params[:order] : "projects.name"
    project_scope = project_scope.order(@order)
    @projects = project_scope.page(params[:page]).per( 20 )

    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.json { render json: @projects }
    end
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
    @project = current_user.all_viewable_projects.find_by_id(params[:id])

    respond_to do |format|
      if @project
        format.html # show.html.erb
        format.json { render json: @project }
      else
        format.html { redirect_to projects_path }
        format.json { head :no_content }
      end
    end
  end

  # GET /projects/new
  # GET /projects/new.json
  def new
    @project = current_user.projects.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @project }
    end
  end

  # GET /projects/1/edit
  def edit
    @project = current_user.all_projects.find_by_id(params[:id])
    redirect_to projects_path unless @project
  end

  # POST /projects
  # POST /projects.json
  def create
    @project = current_user.projects.new(post_params)

    respond_to do |format|
      if @project.save
        format.html { redirect_to @project, notice: 'Project was successfully created.' }
        format.json { render json: @project, status: :created, location: @project }
      else
        format.html { render action: "new" }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /projects/1
  # PUT /projects/1.json
  def update
    @project = current_user.all_projects.find_by_id(params[:id])

    respond_to do |format|
      if @project
        if @project.update_attributes(post_params)
          format.html { redirect_to @project, notice: 'Project was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @project.errors, status: :unprocessable_entity }
        end
      else
        format.html { redirect_to projects_path }
        format.json { head :no_content }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    @project = current_user.all_projects.find_by_id(params[:id])
    @project.destroy if @project

    respond_to do |format|
      format.html { redirect_to projects_path }
      format.json { head :no_content }
    end
  end

  private

  def post_params
    params[:project] ||= {}

    params[:project].slice(
      :name, :description, :emails
    )
  end
end
