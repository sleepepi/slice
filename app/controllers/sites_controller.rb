# frozen_string_literal: true

# Manages access to viewing and editing project sites.
class SitesController < ApplicationController
  before_action :authenticate_user!
  before_action :find_viewable_project_or_redirect, only: [:index, :show]
  before_action :find_editable_project_or_redirect,
                only: [
                  :new, :edit, :create, :update, :destroy, :setup,
                  :add_site_row, :create_sites
                ]
  before_action :find_viewable_site_or_redirect, only: [:show]
  before_action :find_editable_site_or_redirect,
                only: [:edit, :update, :destroy]

  layout "layouts/full_page_sidebar_dark"

  # # GET /setup
  # def setup
  # end

  # # POST /add-site-row.js
  # def add_site_row
  # end

  # POST /create-sites
  def create_sites
    params[:sites].select { |hash| hash[:name].present? }.each do |hash|
      site = @project.sites.find_by(id: hash[:id])
      if site
        if hash[:name] == "Default Site"
          site.update(name: hash[:name])
        else
          site.update(name: hash[:name], short_name: nil)
        end
      else
        @project.sites.create name: hash[:name], user_id: current_user.id
      end
    end
    redirect_to settings_editor_project_path(@project)
  end

  # GET /sites
  def index
    @order = scrub_order(Site, params[:order], "sites.name")
    @sites = viewable_sites.search_any_order(params[:search]).order(@order)
                           .page(params[:page]).per(40)
  end

  # # GET /sites/1
  # def show
  # end

  # GET /sites/new
  def new
    @site = @project.sites.new
  end

  # # GET /sites/1/edit
  # def edit
  # end

  # POST /sites
  def create
    @site = @project.sites.where(user: current_user).new(site_params)
    if @site.save
      redirect_to [@project, @site], notice: "Site was successfully created."
    else
      render :new
    end
  end

  # PATCH /sites/1
  def update
    if @site.update(site_params)
      redirect_to [@project, @site], notice: "Site was successfully updated."
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

  def viewable_sites
    current_user.all_viewable_sites.where(project_id: @project.id)
  end

  def find_viewable_site_or_redirect
    @site = viewable_sites.find_by(id: params[:id])
    redirect_without_site
  end

  def find_editable_site_or_redirect
    @site = current_user.all_editable_sites.where(project_id: @project.id)
                        .find_by(id: params[:id])
    redirect_without_site
  end

  def redirect_without_site
    empty_response_or_root_path(project_sites_path(@project)) unless @site
  end

  def site_params
    params.require(:site).permit(
      :name, :short_name, :number, :description, :subject_code_format
    )
  end
end
