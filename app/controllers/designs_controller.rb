# frozen_string_literal: true

# Designs can be created and updated by project editors and owners.
class DesignsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_viewable_project_or_redirect, only: [:print]
  before_action :find_editable_project_or_redirect, except: [:print]
  before_action :find_viewable_design_or_redirect, only: [:print]
  before_action :find_editable_design_or_redirect, only: [
    :show, :edit, :update, :destroy, :reorder, :upload_images
  ]

  layout "layouts/full_page_sidebar_dark"

  # # POST /projects/:project_id/designs/add_question.js
  # def add_question
  # end

  # GET /projects/:project_id/designs
  def index
    scope = editable_designs.search_any_order(params[:search])
    scope = scope_includes(scope)
    scope = scope_filter(scope)
    @designs = scope_order(scope).page(params[:page]).per(40)
  end

  # This is the latex view
  # GET /projects/:project_id/designs/1/print
  def print
    design_print = @design.design_prints.where(language: World.language).first_or_create
    design_print.regenerate! if design_print.regenerate?
    send_file_if_present design_print.file, type: "application/pdf", disposition: "inline"
  end

  # # GET /projects/:project_id/designs/1
  # def show
  # end

  # # GET /projects/:project_id/designs/1/reorder
  # def reorder
  # end

  # GET /projects/:project_id/designs/new
  def new
    @design = @project.designs.new(design_params)
  end

  # # GET /projects/:project_id/designs/1/edit
  # # GET /projects/:project_id/designs/1/edit.js
  # def edit
  # end

  # POST /projects/:project_id/designs
  def create
    @design = current_user.designs.where(project_id: @project.id).create(design_params)

    if @design.save
      @design.create_variables_from_questions!
      redirect_to edit_project_design_path(@project, @design)
    else
      render :new
    end
  end

  # PATCH /projects/:project_id/designs/1.js
  def update
    if @design.save_translation!(design_params)
      render :show
    else
      render :edit
    end
  end

  # DELETE /projects/:project_id/designs/1
  # DELETE /projects/:project_id/designs/1.js
  def destroy
    @design.destroy
    respond_to do |format|
      format.html { redirect_to project_designs_path(@project) }
      format.js
    end
  end

  # POST /projects/:project_id/upload-images.js
  def upload_images
    @images = @design.attach_images!(params[:files], current_user)
  end

  private

  def find_viewable_design_or_redirect
    @design = current_user.all_viewable_designs.where(project_id: @project.id).find_by_param(params[:id])
    redirect_without_design
  end

  def editable_designs
    current_user.all_designs.where(project_id: @project.id)
  end

  def find_editable_design_or_redirect
    @design = editable_designs.find_by_param(params[:id])
    redirect_without_design
  end

  def redirect_without_design
    empty_response_or_root_path(project_designs_path(@project)) unless @design
  end

  def design_params
    params[:design] ||= {}
    set_survey_slug_and_updater
    parse_redirect_url
    params.require(:design).permit(
      :name, :slug, :survey_slug, :short_name, :project_id, :updater_id, :publicly_available,
      :show_site, :ignore_auto_lock, :category_id, :only_unblinded, :repeated,
      { questions: [:question_name, :question_type] }, :redirect_url,
      :notifications_enabled, :translated
    )
  end

  def set_survey_slug_and_updater
    params[:design][:survey_slug] = params[:design][:survey_slug].parameterize unless params[:design][:survey_slug].blank?
    params[:design][:updater_id] = current_user.id
  end

  def parse_redirect_url
    return unless params[:design].key?(:redirect_url)
    uri = URI.parse(params[:design][:redirect_url])
    params[:design][:redirect_url] = uri.is_a?(URI::HTTP) ? uri.to_s : ""
  rescue
    params[:design][:redirect_url] = ""
  end

  def scope_includes(scope)
    scope.includes(:category)
  end

  def scope_filter(scope)
    [:category_id].each do |key|
      scope = scope.where(key => params[key]) if params[key].present?
    end
    scope
  end

  def scope_order(scope)
    @order = params[:order]
    scope.order(Design::ORDERS[params[:order]] || Design::DEFAULT_ORDER)
  end
end
