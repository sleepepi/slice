# frozen_string_literal: true

# Designs can be created and updated by project editors and owners
class DesignsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_viewable_project,     only: [:print, :report_print, :report, :overview]
  before_action :set_editable_project,     only: [:index, :show, :new, :interactive, :interactive_popup, :edit, :create, :update, :destroy, :copy, :reorder, :add_question]
  before_action :redirect_without_project, only: [:index, :show, :new, :interactive, :interactive_popup, :edit, :create, :update, :destroy, :copy, :reorder, :add_question, :print, :report_print, :report, :overview]
  before_action :set_viewable_design,      only: [:print, :report_print, :report, :overview]
  before_action :set_editable_design,      only: [:show, :edit, :update, :destroy, :reorder]

  # Concerns
  include Buildable

  # POST /designs/add_question.js
  def add_question
  end

  # GET /designs/1/overview
  # GET /designs/1/overview.js
  def overview
    @sheets = current_user.all_viewable_sheets
                          .where(project_id: @project.id, design_id: @design.id)
                          .where(missing: false)
  end

  def report_print
    setup_report_new
    orientation = %w(portrait landscape).include?(params[:orientation].to_s) ? params[:orientation].to_s : 'portrait'
    file_pdf_location = @design.latex_report_new_file_location(
      current_user,
      orientation,
      @report_title,
      @report_subtitle,
      @report_caption,
      @percent,
      @table_header,
      @table_body,
      @table_footer
    )
    if File.exist?(file_pdf_location)
      file_name = @report_title.gsub(' vs. ', ' versus ').gsub(/[^\da-zA-Z ]/, '')
      send_file file_pdf_location,
                filename: "#{file_name} #{Time.zone.now.strftime('%Y.%m.%d %Ih%M %p')}.pdf",
                type: 'application/pdf',
                disposition: 'inline'
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
        message = "Unable to copy design since another design named <b>#{@design.name}</b> already exists.".html_safe
        redirect_to project_designs_path(design.project, search: design.name), alert: message
      end
    else
      redirect_to project_designs_path
    end
  end

  # GET /designs
  # GET /designs.json
  def index
    design_scope = current_user.all_viewable_designs
                               .where(project_id: @project.id).includes(:user)
                               .search(params[:search])
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

  # PATCH /designs/1.js
  def update
    if @design.update(design_params)
      render :show
    else
      render :edit
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
    @design = current_user.all_viewable_designs.find_by_param params[:id]
    redirect_without_design
  end

  def set_editable_design
    @design = current_user.all_designs.where(project_id: @project.id).find_by_param params[:id]
    redirect_without_design
  end

  def redirect_without_design
    empty_response_or_root_path(project_designs_path(@project)) unless @design
  end

  def design_params
    params[:design] ||= {}
    params[:design][:slug] = params[:design][:slug].parameterize unless params[:design][:slug].blank?
    params[:design][:updater_id] = current_user.id
    parse_redirect_url
    params.require(:design).permit(
      :name, :slug, :description, :project_id, :updater_id, :publicly_available, :show_site,
      { questions: [:question_name, :question_type] }, :redirect_url, :category_id, :only_unblinded
    )
  end

  def parse_redirect_url
    return unless params[:design].key?(:redirect_url)
    uri = URI.parse(params[:design][:redirect_url])
    params[:design][:redirect_url] = uri.is_a?(URI::HTTP) ? uri.to_s : ''
  rescue
    params[:design][:redirect_url] = ''
  end
end
