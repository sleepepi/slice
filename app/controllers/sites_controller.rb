class SitesController < ApplicationController
  before_filter :authenticate_user!

  def selection
    @project = Project.current.find_by_id(params[:project_id])
    @subject = @project.subjects.find_by_subject_code(params[:subject_code]) if @project
    @disable_selection = (params[:select] != '1')
  end

  # GET /sites
  # GET /sites.json
  def index
    site_scope = Site.current
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
    @site = Site.current.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @site }
    end
  end

  # GET /sites/new
  # GET /sites/new.json
  def new
    @site = Site.new(params[:site])

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @site }
    end
  end

  # GET /sites/1/edit
  def edit
    @site = Site.current.find(params[:id])
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
    @site = Site.current.find(params[:id])

    respond_to do |format|
      if @site.update_attributes(post_params)
        format.html { redirect_to @site, notice: 'Site was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @site.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sites/1
  # DELETE /sites/1.json
  def destroy
    @site = Site.current.find(params[:id])
    @site.destroy

    respond_to do |format|
      format.html { redirect_to sites_url }
      format.json { head :no_content }
    end
  end

  private

  def parse_date(date_string)
    date_string.to_s.split('/').last.size == 2 ? Date.strptime(date_string, "%m/%d/%y") : Date.strptime(date_string, "%m/%d/%Y") rescue ""
  end

  def post_params
    [].each do |date|
      params[:site][date] = parse_date(params[:site][date])
    end

    params[:site] ||= {}
    params[:site].slice(
      :name, :description, :project_id, :emails
    )
  end
end
