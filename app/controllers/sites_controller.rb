class SitesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_viewable_project, only: [ :index, :show ]
  before_action :set_editable_project, only: [ :new, :edit, :create, :update, :destroy ]
  before_action :redirect_without_project, only: [ :index, :show, :new, :edit, :create, :update, :destroy ]
  before_action :set_viewable_site, only: [ :show ]
  before_action :set_editable_site, only: [ :edit, :update, :destroy ]
  before_action :redirect_without_site, only: [ :show, :edit, :update, :destroy ]

  # GET /sites
  # GET /sites.json
  def index
    current_user.pagination_set!('sites', params[:sites_per_page].to_i) if params[:sites_per_page].to_i > 0
    @order = scrub_order(Site, params[:order], 'sites.name')
    @sites = current_user.all_viewable_sites.search(params[:search]).where(project_id: @project.id).order(@order).page(params[:page]).per( current_user.pagination_count('sites') )
  end

  # GET /sites/1
  # GET /sites/1.json
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
  # POST /sites.json
  def create
    @site = current_user.sites.new(site_params)

    respond_to do |format|
      if @site.save
        format.html { redirect_to [@project, @site], notice: 'Site was successfully created.' }
        format.json { render action: 'show', status: :created, location: @site }
      else
        format.html { render action: 'new' }
        format.json { render json: @site.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /sites/1
  # PUT /sites/1.json
  def update
    respond_to do |format|
      if @site.update(site_params)
        format.html { redirect_to [@project, @site], notice: 'Site was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @site.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sites/1
  # DELETE /sites/1.json
  def destroy
    @site.destroy

    respond_to do |format|
      format.html { redirect_to project_sites_path(@project) }
      format.js
      format.json { head :no_content }
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
        :name, :description, :project_id, :prefix, :code_minimum, :code_maximum
      )
    end

end
