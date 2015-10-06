# Designs can be created and updated by project editors and owners
class DesignsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_viewable_project,                  only: [:print, :report_print, :report, :overview, :master_verification]
  before_action :set_editable_project,                  only: [:index, :show, :new, :interactive, :interactive_popup, :edit, :create, :update, :destroy, :copy, :reorder, :import, :create_import, :progress, :reimport, :update_import, :add_question, :json_import, :json_import_create]
  before_action :redirect_without_project,              only: [:index, :show, :master_verification, :new, :interactive, :interactive_popup, :edit, :create, :update, :destroy, :copy, :reorder, :import, :create_import, :progress, :reimport, :update_import, :add_question, :print, :report_print, :report, :overview, :json_import, :json_import_create]
  before_action :set_viewable_design,                   only: [:print, :report_print, :report, :overview, :master_verification]
  before_action :set_editable_design,                   only: [:show, :edit, :update, :destroy, :reorder, :progress, :reimport, :update_import]
  before_action :redirect_without_design,               only: [:show, :master_verification, :edit, :update, :destroy, :reorder, :print, :report_print, :report, :progress, :reimport, :update_import, :overview]

  # Concerns
  include Buildable

  # POST /designs/add_question.js
  def add_question
  end

  # GET /designs/1/overview
  # GET /designs/1/overview.js
  def overview
    @statuses = params[:statuses] || ['valid']
    @sheets = current_user.all_viewable_sheets.original_entry.where(project_id: @project.id, design_id: @design.id).with_subject_status(@statuses)
  end

  def json_import
  end

  def json_import_create
    json = JSON.parse(params[:json_file].read)
    [json].flatten.each do |design_json|
      @project.create_design_from_json(design_json, current_user)
    end

    redirect_to project_designs_path(@project)
  rescue
    @error = 'JSON File can\'t be blank.'
    render 'json_import'
  end

  def import
    @design = current_user.designs.new(project_id: params[:project_id])
    @variables = []
  end

  # POST /designs/1.js
  def progress
  end

  def create_import
    @design = current_user.designs.where(project_id: @project.id).new(design_params)
    if params[:variables].blank?
      @variables = @design.load_variables
      if @design.csv_file.blank?
        @design.errors.add(:csv_file, 'must be selected')
      end
      @design.name = @design.csv_file.path.split('/').last.gsub(/csv|\./, '').humanize if @design.name.blank? && @design.csv_file.path && @design.csv_file.path.split('/').last
      render :import
    else
      if @design.save
        @design.create_variables!(params[:variables])

        generate_import

        redirect_to [@design.project, @design], notice: 'Design import initialized successfully. You will receive an email when the design import completes.'
      else
        @variables = @design.load_variables
        @design.name = @design.csv_file.path.split('/').last.gsub(/csv|\./, '').humanize.capitalize if @design.name.blank? && @design.csv_file.path && @design.csv_file.path.split('/').last
        render :import
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
    @design.csv_file = params[:design][:csv_file] if params[:design] && !params[:design][:csv_file].blank?
    @design.csv_file_cache = params[:design][:csv_file_cache] if params[:design] && !params[:design][:csv_file_cache].blank?

    if params[:design].blank? || (params[:design][:csv_file].blank? && params[:design][:csv_file_cache].blank?) || !@design.valid?
      @variables = []
      @design.errors.add :csv_file, 'must be selected'
      render :reimport
      return
    end

    if params[:variables].blank?
      @variables = @design.load_variables
      render :reimport
    else
      @design.save
      @design.update rows_imported: 0
      @design.set_total_rows
      generate_import
      redirect_to [@design.project, @design], notice: 'Design import initialized successfully. You will receive an email when the design import completes.'
    end
  end

  def report_print
    setup_report_new

    orientation = %w(portrait landscape).include?(params[:orientation].to_s) ? params[:orientation].to_s : 'portrait'

    file_pdf_location = @design.latex_report_new_file_location(current_user, orientation, @report_title, @report_subtitle, @report_caption, @percent, @table_header, @table_body, @table_footer)

    if File.exist?(file_pdf_location)
      file_name = @report_title.gsub(' vs. ', ' versus ').gsub(/[^\da-zA-Z ]/, '')
      send_file file_pdf_location, filename: "#{file_name} #{Time.zone.now.strftime('%Y.%m.%d %Ih%M %p')}.pdf", type: 'application/pdf', disposition: 'inline'
    else
      render text: 'PDF did not render in time. Please refresh the page.'
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
      @design.name += ' Copy'
      if @design.save
        redirect_to edit_project_design_path(@design.project, @design), notice: 'Design was successfully copied.'
      else
        redirect_to project_designs_path(design.project, search: design.name), alert: "Unable to copy design since another design named <b>#{@design.name}</b> already exists.".html_safe
      end
    else
      redirect_to project_designs_path
    end
  end

  # GET /designs
  # GET /designs.json
  def index
    design_scope = current_user.all_viewable_designs.where(project_id: @project.id).includes(:user).search(params[:search])

    @order = params[:order]
    case params[:order]
    when 'designs.user_name'
      design_scope = design_scope.order_by_user_name
    when 'designs.user_name DESC'
      design_scope = design_scope.order_by_user_name_desc
    else
      @order = scrub_order(Design, params[:order], 'designs.name')
      design_scope = design_scope.order(@order)
    end

    design_scope = design_scope.where(id: params[:design_ids]) unless params[:design_ids].blank?
    design_scope = design_scope.with_user(params[:user_id]) unless params[:user_id].blank?

    @designs = design_scope.page(params[:page]).per(40)
  end

  # This is the latex view
  def print
    file_pdf_location = @design.latex_file_location(current_user)

    if File.exist?(file_pdf_location)
      send_file file_pdf_location, filename: "design_#{@design.id}.pdf", type: 'application/pdf', disposition: 'inline'
    else
      render text: 'PDF did not render in time. Please refresh the page.'
    end
  end

  # GET /designs/1
  # GET /designs/1.json
  def show
  end

  # GET /designs/new
  def new
    @design = @project.designs.new(design_params)
  end

  # GET /designs/1/edit
  def edit
  end

  # POST /designs.js
  def create
    @design = current_user.designs.where(project_id: @project.id).create(design_params)

    if @design.save
      @design.create_variables_from_questions!
      redirect_to edit_project_design_path(@project, @design)
    else
      render :new
    end
  end

  # PUT /designs/1.js
  def update
    if @design.update(design_params)
      render :show
    else
      render :edit
    end
  end

  # # GET /designs/new
  # def new
  #   @design = current_user.designs.new(updater_id: current_user.id, project_id: params[:project_id])
  # end

  # # GET /designs/1/edit
  # def edit
  # end

  # # POST /designs
  # # POST /designs.json
  # def create
  #   @design = current_user.designs.new(design_params)

  #   respond_to do |format|
  #     if @design.save
  #       format.html { redirect_to [@design.project, @design], notice: 'Design was successfully created.' }
  #       format.json { render action: 'show', status: :created, location: @design }
  #     else
  #       format.html { render action: 'new' }
  #       format.json { render json: @design.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # # PUT /designs/1
  # # PUT /designs/1.json
  # def update
  #   respond_to do |format|
  #     if @design.update(design_params)
  #       format.html { redirect_to [@design.project, @design], notice: 'Design was successfully updated.' }
  #       format.json { head :no_content }
  #     else
  #       format.html { render action: 'edit' }
  #       format.json { render json: @design.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

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
    @design = current_user.all_viewable_designs.find_by_id params[:id]
  end

  def set_editable_design
    @design = current_user.all_designs.where(project_id: @project.id).find_by_id params[:id]
  end

  def redirect_without_design
    empty_response_or_root_path(project_designs_path(@project)) unless @design
  end

  def design_params
    params[:design] ||= {}

    params[:design][:slug] = params[:design][:slug].parameterize unless params[:design][:slug].blank?

    params[:design][:updater_id] = current_user.id

    if params[:design].key?(:redirect_url)
      begin
        uri = URI.parse(params[:design][:redirect_url])
        params[:design][:redirect_url] = uri.is_a?(URI::HTTP) ? uri.to_s : ''
      rescue
        params[:design][:redirect_url] = ''
      end
    end

    params.require(:design).permit(
      :name, :slug, :description, :project_id, :updater_id, :csv_file, :csv_file_cache, :publicly_available, :show_site,
      { questions: [:question_name, :question_type] }, :redirect_url, :category_id, :only_unblinded
    )
  end

  def generate_import
    return if Rails.env.test?
    pid = Process.fork
    if pid.nil?
      site = @design.project.sites.find_by_id(params[:site_id])
      subject_status = (Subject::STATUS.flatten.include?(params[:subject_status].to_s) ? params[:subject_status].to_s : 'pending')
      @design.create_sheets!(site, subject_status, current_user, request.remote_ip)
      Kernel.exit!
    else
      Process.detach(pid)
    end
  end
end
