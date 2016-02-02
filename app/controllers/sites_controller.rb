# frozen_string_literal: true

# Manages access to viewing and editing project sites.
class SitesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_viewable_project, only: [:index, :show]
  before_action :set_editable_project, only: [:new, :edit, :create, :update, :destroy]
  before_action :redirect_without_project, only: [:index, :show, :new, :edit, :create, :update, :destroy]
  before_action :set_viewable_site, only: [:show]
  before_action :set_editable_site, only: [:edit, :update, :destroy]
  before_action :redirect_without_site, only: [:show, :edit, :update, :destroy]

  # GET /sites
  def index
    @order = scrub_order(Site, params[:order], 'sites.name')
    @sites = current_user.all_viewable_sites.where(project_id: @project.id)
                         .search(params[:search]).order(@order)
                         .page(params[:page]).per(40)
  end

  # GET /sites/1
  def show
  end

  # GET /sites/new
  def new
    @site = current_user.sites.new(site_params)
  end

  # GET /sites/1/edit
  def edit
  end

  # POST /sites
  def create
    @site = current_user.sites.new(site_params)
    if @site.save
      redirect_to [@project, @site], notice: 'Site was successfully created.'
    else
      render :new
    end
  end

  # PATCH /sites/1
  def update
    if @site.update(site_params)
      redirect_to [@project, @site], notice: 'Site was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /sites/1
  # DELETE /sites/1.js
  def destroy
    @site.destroy
    respond_to do |format|
      format.html { redirect_to project_sites_path(@project) }
      format.js
    end
  end

  private

  def set_viewable_site
    @site = current_user.all_viewable_sites.find_by_id(params[:id])
  end

  def set_editable_site
    @site = @project.sites.find_by_id(params[:id])
  end

  def redirect_without_site
    empty_response_or_root_path(project_sites_path(@project)) unless @site
  end

  def site_params
    params[:site] ||= {}
    params[:site][:project_id] = @project.id
    params.require(:site).permit(
      :name, :description, :project_id, :prefix, :code_minimum, :code_maximum,
      :subject_code_format
    )
  end
end
