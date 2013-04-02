class ProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_viewable_project, only: [ :settings, :show, :subject_report, :report, :report_print, :filters, :new_filter, :edit_filter, :update_filter ]
  before_action :set_editable_project, only: [ :edit, :update, :destroy, :remove_file ]
  before_action :redirect_without_project, only: [ :settings, :show, :subject_report, :report, :report_print, :edit, :update, :destroy, :remove_file, :filters, :new_filter, :edit_filter, :update_filter ]

  # Concerns
  include Buildable

  def new_filter
    @design = @project.designs.find_by_id(params[:design_id])
  end

  def edit_filter
    @variable = @project.variable_by_id(params[:variable_id])
  end

  def update_filter
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
      File.open(file_pdf_location, 'r') do |file|
        file_name = @report_title.gsub(' vs. ', ' versus ').gsub(/[^\da-zA-Z ]/, '')
        send_file file, filename: "#{file_name} #{Time.now.strftime("%Y.%m.%d %Ih%M %p")}.pdf", type: "application/pdf", disposition: "inline"
      end
    else
      render text: "PDF did not render in time. Please refresh the page."
    end
  end

  # def report
  #   setup_report
  # end

  def remove_file
    @project.remove_logo!
  end

  # GET /projects
  # GET /projects.json
  def index
    current_user.pagination_set!('projects', params[:projects_per_page].to_i) if params[:projects_per_page].to_i > 0
    @order = scrub_order(Project, params[:order], 'projects.name')
    @projects = current_user.all_viewable_projects.search(params[:search]).order(@order).page(params[:page]).per( current_user.pagination_count('projects') )
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
        format.html { redirect_to settings_project_path(@project), notice: 'Project was successfully updated.' }
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

    def redirect_without_project
      super(projects_path)
    end

    def project_params
      params.require(:project).permit(
        :name, :description, :emails, :acrostic_enabled, :subject_code_name,
        :show_contacts, :show_documents, :show_posts,
        # Uploaded Logo
        :logo, :logo_uploaded_at, :logo_cache,
        # Will automatically generate a site if the project has no site
        :site_name
      )
    end

    def setup_report
      @sheet_before = parse_date(params[:sheet_before])
      @sheet_after = parse_date(params[:sheet_after])

      @by = ["week", "month", "year"].include?(params[:by]) ? params[:by] : "month" # "month" or "year"
      @percent = ['none', 'row', 'column'].include?(params[:percent]) ? params[:percent] : 'none'
      @statuses = params[:statuses] || ['valid']

      sheet_scope = current_user.all_viewable_sheets.with_project(@project.id)
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

end
