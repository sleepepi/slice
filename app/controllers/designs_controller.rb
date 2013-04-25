class DesignsController < ApplicationController
  before_action :authenticate_user!,        except: [ :survey ]
  before_action :set_viewable_project,      only: [ :print, :report_print, :report, :blank, :overview ]
  before_action :set_editable_project,      only: [ :index, :show, :new, :edit, :create, :update, :destroy, :copy, :add_section, :add_variable, :variables, :reorder, :batch, :create_batch, :import, :create_import, :progress, :reimport, :update_import ]
  before_action :redirect_without_project,  only: [ :index, :show, :new, :edit, :create, :update, :destroy, :copy, :add_section, :add_variable, :variables, :reorder, :batch, :create_batch, :print, :report_print, :report, :reporter, :import, :create_import, :progress, :blank, :reimport, :update_import, :overview ]
  before_action :set_viewable_design,       only: [ :print, :report_print, :report, :blank, :overview ]
  before_action :set_editable_design,       only: [ :show, :edit, :update, :destroy, :reorder, :progress, :reimport, :update_import ]
  before_action :redirect_without_design,   only: [ :show, :edit, :update, :destroy, :reorder, :print, :report_print, :report, :progress, :blank, :reimport, :update_import, :overview ]

  # Concerns
  include Buildable

  # Get /designs/1/overview
  # Get /designs/1/overview.js
  def overview
    @statuses = params[:statuses] || ['valid', 'pending', 'test']
    @sheets = current_user.all_viewable_sheets.where( project_id: @project.id, design_id: @design.id ).with_subject_status(@statuses)
  end

  def survey
    @project = Project.current.find_by_id(params[:project_id])
    @design = @project.designs.find_by_id(params[:id]) if @project
    empty_response_or_root_path(about_path) unless @design and @design.publicly_available?
  end

  def blank
  end

  def import
    @design = current_user.designs.new(project_id: params[:project_id])
    @variables = []
  end

  # POST /designs/1.js
  def progress
  end

  def create_import
    @design = current_user.designs.new(design_params)
    if params[:variables].blank?
      @variables = @design.load_variables
      if @design.csv_file.blank?
        @design.errors.add(:csv_file, "must be selected")
      # elsif not @design.header_row.include?('Subject')
      #   @design.errors.add(:csv_file, "must contain Subject as a header column")
      end
      @design.name = @design.csv_file.path.split('/').last.gsub(/csv|\./, '').humanize if @design.name.blank? and @design.csv_file.path and @design.csv_file.path.split('/').last
      render "import"
    else
      if @design.save
        @design.create_variables!(params[:variables])

        generate_import

        redirect_to [@design.project, @design], notice: 'Design import initialized successfully. You will receive an email when the design import completes.'
      else
        @variables = @design.load_variables
        @design.name = @design.csv_file.path.split('/').last.gsub(/csv|\./, '').humanize.capitalize if @design.name.blank? and @design.csv_file.path and @design.csv_file.path.split('/').last
        render "import"
      end
    end
  end

  # GET /designs/1/reimport
  def reimport
    @design.remove_csv_file!
    @variables = []
  end

  # PATCH /designs/1/update_import
  def update_import
    if params[:design].blank? or (params[:design][:csv_file].blank? and params[:design][:csv_file_cache].blank?)
      @variables = []
      @design.errors.add(:csv_file, "must be selected")
      render "reimport"
      return
    end

    @design.csv_file = params[:design][:csv_file] if not params[:design].blank? and not params[:design][:csv_file].blank?
    @design.csv_file_cache = params[:design][:csv_file_cache] if not params[:design].blank? and not params[:design][:csv_file_cache].blank?

    if params[:variables].blank?
      @design.save
      @variables = @design.load_variables
      render "reimport"
    else
      @design.save
      @design.update( rows_imported: 0 )
      @design.set_total_rows
      generate_import
      redirect_to [@design.project, @design], notice: 'Design import initialized successfully. You will receive an email when the design import completes.'
    end

  end


  def report_print
    setup_report_new

    orientation = ['portrait', 'landscape'].include?(params[:orientation].to_s) ? params[:orientation].to_s : 'portrait'

    file_pdf_location = @design.latex_report_new_file_location(current_user, orientation, @report_title, @report_subtitle, @report_caption, @percent, @table_header, @table_body, @table_footer)

    if File.exists?(file_pdf_location)
      file_name = @report_title.gsub(' vs. ', ' versus ').gsub(/[^\da-zA-Z ]/, '')
      send_file file_pdf_location, filename: "#{file_name} #{Time.now.strftime("%Y.%m.%d %Ih%M %p")}.pdf", type: "application/pdf", disposition: "inline"
    else
      render text: "PDF did not render in time. Please refresh the page."
    end
  end


  def report
    setup_report_new
    generate_table_csv_new if params[:format] == 'csv'
  end

  def copy
    design = current_user.all_viewable_designs.find_by_id(params[:id])
    @design = current_user.designs.new(design.copyable_attributes) if design

    if @design
      render 'new'
    else
      redirect_to project_designs_path
    end
  end

  def selection
    @project = current_user.all_viewable_projects.find_by_id(params[:project_id])
    @sheet = current_user.all_sheets.find_by_id(params[:sheet_id])
    @sheet = Sheet.new unless @sheet
    @design = current_user.all_viewable_designs.find_by_id(params[:sheet][:design_id]) unless params[:sheet].blank?
  end

  def add_section
    @design = Design.new(design_params.except(:option_tokens))
    @option = { }
  end

  def add_variable
    @design = Design.new(design_params)
    @option = { variable_id: '' }
    @all_viewable_variables = current_user.all_viewable_variables.where(project_id: @project.id)
    @select_variables = @all_viewable_variables.order(:name).collect{|v| [v.name, v.id]}
  end

  def variables
    @design = Design.new(design_params)
  end

  def reorder
    if params[:rows].blank?
      @design.reorder_sections(params[:sections].to_s.split(','), current_user)
    else
      @design.reorder(params[:rows].to_s.split(','), current_user)
    end
  end

  def batch
    @designs = @project.designs
    @sites = @project.sites
    @emails = []
  end

  def create_batch
    @design = @project.designs.find_by_id(params[:design_id])
    @site = @project.sites.find_by_id(params[:site_id])
    @emails = params[:emails].to_s.split(/[;\r\n]/).collect{|email| email.strip}.select{|email| not email.blank?}.uniq

    if @design and @site and not @emails.blank?
      (sheets_created, sheets_ignored) = @design.batch_sheets!(current_user, @site, @emails, params[:additional_text])
      flash[:notice] = "#{sheets_created} #{sheets_created == 1 ? 'sheet was' : 'sheets were'} successfully created." if sheets_created > 0
      flash[:alert] = "#{sheets_ignored} #{sheets_ignored == 1 ? 'sheet was' : 'sheets were'} not created because the #{sheets_ignored == 1 ? 'subject exists' : 'subjects exist'} on a different site." if sheets_ignored > 0
      redirect_to project_sheets_path(@project, site_id: @site.id, design_id: @design.id, user_id: current_user.id)
    else
      redirect_to batch_project_designs_path(emails: @emails.join('; '), site_id: @site ? @site.id : nil, design_id: @design ? @design.id : nil ), alert: 'Please select a design, site, and valid emails.'
    end
  end

  # GET /designs
  # GET /designs.json
  def index
    current_user.pagination_set!('designs', params[:designs_per_page].to_i) if params[:designs_per_page].to_i > 0

    design_scope = current_user.all_viewable_designs.search(params[:search])

    @order = params[:order]
    case params[:order] when 'designs.user_name'
      design_scope = design_scope.order_by_user_name
    when 'designs.user_name DESC'
      design_scope = design_scope.order_by_user_name_desc
    else
      @order = scrub_order(Design, params[:order], 'designs.name')
      design_scope = design_scope.order(@order)
    end

    design_scope = design_scope.where(id: params[:design_ids]) unless params[:design_ids].blank?

    ['project', 'user'].each do |filter|
      design_scope = design_scope.send("with_#{filter}", params["#{filter}_id".to_sym]) unless params["#{filter}_id".to_sym].blank?
    end

    @designs = design_scope.page(params[:page]).per( current_user.pagination_count('designs') )
  end

  # This is the latex view
  def print
    file_pdf_location = @design.latex_file_location(current_user)

    if File.exists?(file_pdf_location)
      send_file file_pdf_location, filename: "design_#{@design.id}.pdf", type: "application/pdf", disposition: "inline"
    else
      render text: "PDF did not render in time. Please refresh the page."
    end
  end

  # GET /designs/1
  # GET /designs/1.json
  def show
  end

  # GET /designs/new
  def new
    @design = current_user.designs.new(updater_id: current_user.id, project_id: params[:project_id])
  end

  # GET /designs/1/edit
  def edit
  end

  # POST /designs
  # POST /designs.json
  def create
    @design = current_user.designs.new(design_params)

    respond_to do |format|
      if @design.save
        format.html { redirect_to [@design.project, @design], notice: 'Design was successfully created.' }
        format.json { render action: 'show', status: :created, location: @design }
      else
        format.html { render action: 'new' }
        format.json { render json: @design.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /designs/1
  # PUT /designs/1.json
  def update
    respond_to do |format|
      if @design.update(design_params)
        format.html { redirect_to [@design.project, @design], notice: 'Design was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @design.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /designs/1
  # DELETE /designs/1.json
  def destroy
    @design.destroy

    respond_to do |format|
      format.html { redirect_to project_designs_path(@project) }
      format.js
      format.json { head :no_content }
    end
  end

  private

    def set_viewable_design
      @design = current_user.all_viewable_designs.find_by_id(params[:id])
    end

    def set_editable_design
      @design = @project.designs.find_by_id(params[:id])
    end

    def redirect_without_design
      empty_response_or_root_path(project_designs_path(@project)) unless @design
    end

    def design_params
      params[:design] ||= {}

      params[:design][:updater_id] = current_user.id
      params[:design][:project_id] = @project.id

      params.require(:design).permit(
        :name, :description, :project_id, { :option_tokens => [ :variable_id, :branching_logic, :section_name, :section_id, :section_description ] }, :email_template, :email_subject_template, :updater_id, :csv_file, :csv_file_cache, :publicly_available
      )
    end

    def generate_import
      rake_task = "#{RAKE_PATH} design_import DESIGN_ID=#{@design.id} SITE_ID=#{params[:site_id].to_i} SUBJECT_STATUS=#{Subject::STATUS.flatten.include?(params[:subject_status].to_s) ? params[:subject_status].to_s : 'pending' } &"
      systemu rake_task unless Rails.env.test?
    end
end
