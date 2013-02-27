class SitesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_viewable_project, only: [ :index, :show ]
  before_action :set_editable_project, only: [ :new, :edit, :create, :update, :destroy, :selection ]
  before_action :redirect_without_project, only: [ :index, :show, :new, :edit, :create, :update, :destroy, :selection ]
  before_action :set_viewable_site, only: [ :show ]
  before_action :set_editable_site, only: [ :edit, :update, :destroy ]
  before_action :redirect_without_site, only: [ :show, :edit, :update, :destroy ]


  def selection
    @subject = @project.subjects.find_by_subject_code(params[:subject_code])
    @disable_selection = (params[:select] != '1')
  end

  # GET /sites
  # GET /sites.json
  def index
    current_user.pagination_set!('sites', params[:sites_per_page].to_i) if params[:sites_per_page].to_i > 0
    @order = scrub_order(Site, params[:order], 'sites.name')
    site_scope = current_user.all_viewable_sites.search(params[:search])
    site_scope = site_scope.where(project_id: params[:project_id]) unless params[:project_id].blank?
    @sites = site_scope.order(@order).page(params[:page]).per( current_user.pagination_count('sites') )

    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.json { render json: @sites }
    end
  end

  # GET /sites/1
  # GET /sites/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @site }
    end
  end

  # GET /sites/new
  # GET /sites/new.json
  def new
    @site = current_user.sites.new(post_params)

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @site }
    end
  end

  # GET /sites/1/edit
  def edit

  end

  # POST /sites
  # POST /sites.json
  def create
    @site = current_user.sites.new(post_params)

    respond_to do |format|
      if @site.save
        format.html { redirect_to [@project, @site], notice: 'Site was successfully created.' }
        format.json { render json: @site, status: :created, location: @site }
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
      if @site.update_attributes(post_params)
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
      format.js { render 'destroy' }
      format.json { head :no_content }
    end
  end

  private

  def post_params
    params[:site] ||= {}

    if current_user.all_viewable_projects.pluck(:id).include?(params[:project_id].to_i)
      params[:site][:project_id] = params[:project_id]
    else
      params[:site][:project_id] = nil
    end

    params[:site].slice(
      :name, :description, :project_id, :emails, :prefix, :code_minimum, :code_maximum
    )
  end

  def set_viewable_site
    @site = current_user.all_viewable_sites.find_by_id(params[:id])
  end

  def set_editable_site
    @site = @project.sites.find_by_id(params[:id])
  end

  def redirect_without_site
    empty_response_or_root_path(project_sites_path) unless @site
  end

end
