class ProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_viewable_project,      only: [ :settings, :show, :collect, :explore, :share, :about, :subject_report, :report, :report_print, :filters, :new_filter, :edit_filter, :favorite, :activity, :logo ]
  before_action :set_editable_project,      only: [ :setup, :edit, :update, :invite_user ]
  before_action :set_owner_project,         only: [ :transfer, :destroy ]
  before_action :redirect_without_project,  only: [ :settings, :show, :collect, :explore, :share, :about, :subject_report, :report, :report_print, :filters, :new_filter, :edit_filter, :favorite, :activity, :setup, :edit, :update, :invite_user, :transfer, :destroy, :logo ]

  # Concerns
  include Buildable

  # POST /projects/save_project_order.js
  def save_project_order
    page = [params[:page].to_i,1].max
    params[:project_ids].each_with_index do |project_id, index|
      project_favorite = current_user.project_favorites.where(project_id: project_id).first_or_create
      project_favorite.update( position: ((page - 1) * Project::PER_PAGE) + index )
    end
    render nothing: true
  end

  def logo
    send_file File.join( CarrierWave::Uploader::Base.root, @project.logo.url )
  end

  def invite_user
    invite_email = params[:invite_email].to_s.strip
    @user = current_user.associated_users.find_by_email(invite_email.split('[').last.to_s.split(']').first)
    @site = @project.sites.find_by_id(params[:site_id])

    if @site
      member_scope = @site.site_users.where(project_id: @project)
    else
      member_scope = @project.project_users
    end

    if @user
      @member = member_scope.where(user_id: @user.id).first_or_create( creator_id: current_user.id )
      @member.update( editor: (params[:editor] == '1') )
    elsif not invite_email.blank?
      @member = member_scope.where(invite_email: invite_email).first_or_create( creator_id: current_user.id )
      @member.update( editor: (params[:editor] == '1') )
      @member.generate_invite_token!
    end

    render 'projects/members'
  end

  def transfer
    if transfer_to = @project.users.find_by_id(params[:user_id])
      @project.update( user_id: transfer_to.id )
      @project_user = @project.project_users.where(user_id: current_user.id).first_or_create( creator_id: transfer_to.id )
      @project_user.update( editor: true )
      flash[:notice] = "Project was successfully transferred to #{transfer_to.name}."
    end
    redirect_to setup_project_path(@project)
  end

  def favorite
    project_favorite = @project.project_favorites.where( user_id: current_user.id ).first_or_create
    project_favorite.update favorite: (params[:favorite] == '1')
    if current_user.beta_enabled?
      redirect_to root_path
    else
      redirect_to @project
    end
  end

  def new_filter
    @design = @project.designs.find_by_id(params[:design_id])
  end

  def edit_filter
    @variable = @project.variable_by_id(params[:variable_id])
  end

  def filters
  end

  def search
    @subjects = current_user.all_viewable_subjects.search(params[:q]).order('subject_code').limit(10)
    @projects = current_user.all_viewable_projects.search(params[:q]).order('name').limit(10)
    @designs = current_user.all_viewable_designs.search(params[:q]).order('name').limit(10)
    @variables = current_user.all_viewable_variables.search(params[:q]).order('name').limit(10)

    @objects = @subjects + @projects + @designs + @variables

    respond_to do |format|
      format.json { render json: ([params[:q]] + @objects.collect(&:name)).uniq }
      format.html do
        redirect_to [@objects.first.project, @objects.first] if @objects.size == 1 and @objects.first.respond_to?('project')
        redirect_to @objects.first if @objects.size == 1 and not @objects.first.respond_to?('project')
      end
    end
  end

  # GET /projects/1/subject_report
  # GET /projects/1/subject_report.js
  def subject_report
    @statuses = params[:statuses] || ['valid']
    @subjects = @project.subjects.where(site_id: current_user.all_viewable_sites.pluck(:id), status: @statuses).order('subject_code').page(params[:page]).per( 40 )
    @designs = @project.designs.order('name')
  end

  # GET /projects/1/splash
  # GET /projects/1/splash.js
  def splash
    flash.delete(:notice)
    @projects = current_user.all_viewable_and_site_projects.by_favorite(current_user.id).order("(favorite IS NULL or favorite = 'f') ASC, name").page(params[:page]).per( 8 )
    redirect_to @projects.first if @projects.total_count == 1
  end

  def report
    params[:f] = [{ id: 'design', axis: 'row', missing: '0' }, { id: 'sheet_date', axis: 'col', missing: '0', by: params[:by] || 'month' }]
    setup_report_new
    generate_table_csv_new if params[:format] == 'csv'
  end

  def report_print
    params[:f] = [{ id: 'design', axis: 'row', missing: '0' }, { id: 'sheet_date', axis: 'col', missing: '0', by: params[:by] || 'month' }]
    setup_report_new
    orientation = ['portrait', 'landscape'].include?(params[:orientation].to_s) ? params[:orientation].to_s : 'portrait'

    @design = @project.designs.new( name: 'Summary Report' )

    file_pdf_location = @design.latex_report_new_file_location(current_user, orientation, @report_title, @report_subtitle, @report_caption, @percent, @table_header, @table_body, @table_footer)

    if File.exists?(file_pdf_location)
      file_name = @report_title.gsub(' vs. ', ' versus ').gsub(/[^\da-zA-Z ]/, '')
      send_file file_pdf_location, filename: "#{file_name} #{Time.now.strftime("%Y.%m.%d %Ih%M %p")}.pdf", type: "application/pdf", disposition: "inline"
    else
      render text: "PDF did not render in time. Please refresh the page."
    end
  end

  # GET /projects
  # GET /projects.json
  def index
    @order = scrub_order(Project, params[:order], 'projects.name')
    @projects = current_user.all_viewable_projects.search(params[:search]).order(@order).page(params[:page]).per( 40 )
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
  end

  # GET /projects/1/settings
  def settings
  end

  # GET /projects/new
  def new
    @project = current_user.projects.new
  end

  # GET /projects/1/edit
  def edit
  end

  # POST /projects
  # POST /projects.json
  def create
    @project = current_user.projects.new(project_params)

    respond_to do |format|
      if @project.save
        format.html { redirect_to @project, notice: 'Project was successfully created.' }
        format.json { render action: 'show', status: :created, location: @project }
      else
        format.html { render action: 'new' }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /projects/1
  # PUT /projects/1.json
  def update
    respond_to do |format|
      if @project.update(project_params)
        format.html { redirect_to setup_project_path(@project), notice: 'Project was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    @project.destroy

    respond_to do |format|
      format.html { redirect_to projects_path }
      format.js { render 'destroy' }
      format.json { head :no_content }
    end
  end

  private

    # Overwriting application_controller
    def set_viewable_project
      super(:id)
      # @project = current_user.all_viewable_and_site_projects.find_by_id(params[:id])
    end

    # Overwriting application_controller
    def set_editable_project
      super(:id)
      # @project = current_user.all_projects.find_by_id(params[:id])
    end

    def set_owner_project
      @project = current_user.projects.find_by_param(params[:id])
    end

    def redirect_without_project
      super(projects_path)
    end

    def project_params
      params.require(:project).permit(
        :name, :slug, :description, :acrostic_enabled, :subject_code_name,
        :show_contacts, :show_documents, :show_posts, :disable_all_emails,
        :collect_email_on_surveys, :lockable, :hide_values_on_pdfs,
        :double_data_entry,
        # Uploaded Logo
        :logo, :logo_uploaded_at, :logo_cache, :remove_logo,
        # Will automatically generate a site if the project has no site
        :site_name
      )
    end

end
