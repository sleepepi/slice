class SitesController < ApplicationController
  before_filter :authenticate_user!

  def selection
    @project = current_user.all_viewable_projects.find_by_id(params[:project_id])
    @subject = @project.subjects.find_by_subject_code(params[:subject_code]) if @project
    @disable_selection = (params[:select] != '1')
  end

  # GET /sites
  # GET /sites.json
  def index
    site_scope = current_user.all_viewable_sites

    ['project'].each do |filter|
      site_scope = site_scope.send("with_#{filter}", params["#{filter}_id".to_sym]) unless params["#{filter}_id".to_sym].blank?
    end

    @search_terms = params[:search].to_s.gsub(/[^0-9a-zA-Z]/, ' ').split(' ')
    @search_terms.each{|search_term| site_scope = site_scope.search(search_term) }

    @order = Site.column_names.collect{|column_name| "sites.#{column_name}"}.include?(params[:order].to_s.split(' ').first) ? params[:order] : "sites.name"
    site_scope = site_scope.order(@order)
    @sites = site_scope.page(params[:page]).per( 20 )

    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.json { render json: @sites }
    end
  end

  # GET /sites/1
  # GET /sites/1.json
  def show
    @site = current_user.all_viewable_sites.find_by_id(params[:id])

    respond_to do |format|
      if @site
        format.html # show.html.erb
        format.json { render json: @site }
      else
        format.html { redirect_to sites_path }
        format.json { head :no_content }
      end
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
    @site = current_user.all_sites.find_by_id(params[:id])
    redirect_to sites_path unless @site
  end

  # POST /sites
  # POST /sites.json
  def create
    @site = current_user.sites.new(post_params)

    respond_to do |format|
      if @site.save
        format.html { redirect_to @site, notice: 'Site was successfully created.' }
        format.json { render json: @site, status: :created, location: @site }
      else
        format.html { render action: "new" }
        format.json { render json: @site.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /sites/1
  # PUT /sites/1.json
  def update
    @site = current_user.all_sites.find_by_id(params[:id])

    respond_to do |format|
      if @site
        if @site.update_attributes(post_params)
          format.html { redirect_to @site, notice: 'Site was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @site.errors, status: :unprocessable_entity }
        end
      else
        format.html { redirect_to sites_path }
        format.json { head :no_content }
      end
    end
  end

  # DELETE /sites/1
  # DELETE /sites/1.json
  def destroy
    @site = current_user.all_sites.find_by_id(params[:id])
    @site.destroy if @site

    respond_to do |format|
      format.html { redirect_to sites_path }
      format.json { head :no_content }
    end
  end

  private

  def post_params
    [].each do |date|
      params[:site][date] = parse_date(params[:site][date])
    end

    params[:site][:project_id] = nil unless current_user.all_viewable_projects.pluck(:id).include?(params[:site][:project_id].to_i)

    params[:site] ||= {}
    params[:site].slice(
      :name, :description, :project_id, :emails
    )
  end
end
