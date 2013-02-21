class ProjectsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :set_viewable_project, only: [ :settings, :show, :subject_report, :report ] # only: [:settings, :show]
  before_filter :set_editable_project, only: [ :edit, :update, :destroy, :remove_file ]
  before_filter :redirect_without_project, only: [ :settings, :show, :subject_report, :report, :edit, :update, :destroy, :remove_file ]

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

  def subject_report
    current_user.pagination_set!('subjects', params[:subjects_per_page].to_i) if params[:subjects_per_page].to_i > 0
    @statuses = params[:statuses] || ['valid', 'pending', 'test']
    @subjects = @project.subjects.where(site_id: current_user.all_viewable_sites.pluck(:id), status: @statuses).order('subject_code').page(params[:page]).per( current_user.pagination_count('subjects') )
    @designs = @project.designs.order('name')

    respond_to do |format|
      format.html # subject_report.html.erb
      format.json { render json: @project }
      format.js { render 'subject_report' }
    end
  end

  def splash
    @projects = current_user.all_viewable_and_site_projects.order(:name).page(params[:page]).per( 8 ) # current_user.pagination_count('projects') )
    redirect_to @projects.first if @projects.total_count == 1
  end

  def report
    setup_report

    respond_to do |format|
      format.html # report.html.erb
      format.json { render json: @project }
      format.js { render 'report' }
    end
  end

  def remove_file
    @project.remove_logo!
  end

  # GET /projects
  # GET /projects.json
  def index
    current_user.pagination_set!('projects', params[:projects_per_page].to_i) if params[:projects_per_page].to_i > 0
    @order = scrub_order(Project, params[:order], 'projects.name')
    @projects = current_user.all_viewable_projects.search(params[:search]).order(@order).page(params[:page]).per( current_user.pagination_count('projects') )

    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.json { render json: @projects }
    end
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @project }
    end
  end

  # GET /projects/1/settings
  def settings

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
    respond_to do |format|
      if @project.update_attributes(post_params)
        format.html { redirect_to settings_project_path(@project), notice: 'Project was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
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

  def setup_report
    @sheet_before = parse_date(params[:sheet_before])
    @sheet_after = parse_date(params[:sheet_after])

    @by = ["week", "month", "year"].include?(params[:by]) ? params[:by] : "month" # "month" or "year"
    @percent = ['none', 'row', 'column'].include?(params[:percent]) ? params[:percent] : 'none'
    @statuses = params[:statuses] || ['valid']

    sheet_scope = current_user.all_viewable_sheets.with_project(@project.id).scoped()
    sheet_scope = sheet_scope.sheet_after(@sheet_after) unless @sheet_after.blank?
    sheet_scope = sheet_scope.sheet_before(@sheet_before) unless @sheet_before.blank?

    sheet_scope = sheet_scope.with_subject_status(@statuses)

    min = sheet_scope.collect{|s| s.created_at.to_date}.min || Date.today
    max = sheet_scope.collect{|s| s.created_at.to_date}.max || Date.today

    # @ranges = [{ name: "2012", start_date: "2012-01-01", end_date: "2012-12-31" }, { name: "2013", start_date: "2013-01-01", end_date: "2013-12-31" }]
    @ranges = []

    case @by when "week"
      current_cweek = min.cweek
      (min.year..max.year).each do |year|
        (current_cweek..Date.parse("#{year}-12-28").cweek).each do |cweek|
          start_date = Date.commercial(year,cweek) - 1.day
          end_date = Date.commercial(year,cweek) + 5.days
          @ranges << { name: "Week #{cweek}", tooltip: "#{year} #{start_date.strftime("%m/%d")}-#{end_date.strftime("%m/%d")} Week #{cweek}", start_date: start_date, end_date: end_date }
          break if year == max.year and cweek == max.cweek
        end
        current_cweek = 1
      end
    when "month"
      current_month = min.month
      (min.year..max.year).each do |year|
        (current_month..12).each do |month|
          start_date = Date.parse("#{year}-#{month}-01")
          end_date = Date.parse("#{year}-#{month}-01").end_of_month
          @ranges << { name: "#{Date::ABBR_MONTHNAMES[month]} #{year}", tooltip: "#{Date::MONTHNAMES[month]} #{year}", start_date: start_date, end_date: end_date }
          break if year == max.year and month == max.month
        end
        current_month = 1
      end
    when "year"
      @ranges = (min.year..max.year).collect{|year| { name: year.to_s, tooltip: year.to_s, start_date: Date.parse("#{year}-01-01"), end_date: Date.parse("#{year}-12-31") }}
    end

    between = if @sheet_after.blank? and @sheet_before.blank?
      "All Sheets"
    elsif @sheet_after.blank?
      "Date before #{@sheet_before.strftime("%b %d, %Y")}"
    elsif @sheet_before.blank?
      "Date after #{@sheet_after.strftime("%b %d, %Y")}"
    else
      "Date between #{@sheet_after.strftime("%b %d, %Y")} and #{@sheet_before.strftime("%b %d, %Y")}"
    end

    @report_title = 'Design vs. Sheet Creation Date'
    @report_caption = "#{@project.name}"

    @sheets = sheet_scope
  end

  def post_params
    params[:project] ||= {}

    params[:project].slice(
      :name, :description, :emails, :acrostic_enabled, :subject_code_name,
      :show_contacts, :show_documents, :show_posts,
      # Uploaded Logo
      :logo, :logo_uploaded_at, :logo_cache
    )
  end

  def redirect_without_project
    empty_response_or_root_path(projects_path) unless @project
  end
end
