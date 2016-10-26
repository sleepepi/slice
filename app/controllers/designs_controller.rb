# frozen_string_literal: true

# Designs can be created and updated by project editors and owners
class DesignsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_viewable_project_or_redirect, only: [:print]
  before_action :find_editable_project_or_redirect, except: [:print]
  before_action :find_viewable_design_or_redirect, only: [:print]
  before_action :find_editable_design_or_redirect, only: [:show, :edit, :update, :destroy, :reorder]

  # POST /designs/add_question.js
  def add_question
  end

  # GET /designs
  def index
    design_scope = editable_designs.search(params[:search])
    design_scope = sort_order(design_scope)
    design_scope = design_scope.where(category_id: params[:category_id]) if params[:category_id].present?
    @designs = design_scope.page(params[:page]).per(40)
  end

  # This is the latex view
  def print
    file_pdf_location = @design.latex_file_location(current_user)
    if File.exist?(file_pdf_location)
      send_file file_pdf_location, filename: "design_#{@design.id}.pdf", type: 'application/pdf', disposition: 'inline'
    else
      # TODO: Redirect to a location that a viewer could see as well, perhaps
      # the basic design report project_reports_basic(@project, @design)
      redirect_to [@project, @design]
    end
  end

  # GET /designs/1
  def show
  end

  # GET /designs/new
  def new
    @design = @project.designs.new(design_params)
  end

  # GET /designs/1/edit
  # GET /designs/1/edit.js
  def edit
  end

  # POST /designs
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
  # DELETE /designs/1.js
  def destroy
    @design.destroy

    respond_to do |format|
      format.html { redirect_to project_designs_path(@project) }
      format.js
    end
  end

  private

  def find_viewable_design_or_redirect
    @design = current_user.all_viewable_designs.where(project_id: @project.id).find_by_param params[:id]
    redirect_without_design
  end

  def editable_designs
    current_user.all_designs.where(project_id: @project.id)
  end

  def find_editable_design_or_redirect
    @design = editable_designs.find_by_param params[:id]
    redirect_without_design
  end

  def redirect_without_design
    empty_response_or_root_path(project_designs_path(@project)) unless @design
  end

  def design_params
    params[:design] ||= {}
    set_slug_and_updater
    parse_redirect_url
    params.require(:design).permit(
      :name, :slug, :short_name, :description, :project_id, :updater_id,
      :publicly_available, :show_site, :ignore_auto_lock, :category_id,
      :only_unblinded,
      { questions: [:question_name, :question_type] }, :redirect_url
    )
  end

  def set_slug_and_updater
    params[:design][:slug] = params[:design][:slug].parameterize unless params[:design][:slug].blank?
    params[:design][:updater_id] = current_user.id
  end

  def parse_redirect_url
    return unless params[:design].key?(:redirect_url)
    uri = URI.parse(params[:design][:redirect_url])
    params[:design][:redirect_url] = uri.is_a?(URI::HTTP) ? uri.to_s : ''
  rescue
    params[:design][:redirect_url] = ''
  end

  def sort_order(design_scope)
    @order = params[:order]
    case params[:order]
    when 'designs.category_name'
      design_scope.includes(:category).order('categories.name', :name)
    when 'designs.category_name desc'
      design_scope.includes(:category).order('categories.name desc', :name)
    else
      @order = scrub_order(Design, params[:order], 'designs.name')
      design_scope.order(@order)
    end
  end
end
