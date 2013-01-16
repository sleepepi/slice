class LinksController < ApplicationController
  before_filter :authenticate_user!

  # GET /links
  # GET /links.json
  def index
    @project = current_user.all_projects.find_by_id(params[:project_id])

    if @project
      link_scope = @project.links.scoped()
      @order = scrub_order(Link, params[:order], "links.name")
      link_scope = link_scope.order(@order)
      @link_count = link_scope.count
      @links = link_scope.page(params[:page]).per( 20 )
    end

    respond_to do |format|
      if @project
        format.html # index.html.erb
        format.js
        format.json { render json: @links }
      else
        format.html { redirect_to root_path }
        format.js { render nothing: true }
        format.json { head :no_content }
      end
    end
  end

  # GET /links/1
  # GET /links/1.json
  def show
    @project = current_user.all_projects.find_by_id(params[:project_id])
    @link = @project.links.find_by_id(params[:id]) if @project

    respond_to do |format|
      if @project
        format.html # show.html.erb
        format.json { render json: @link }
      else
        format.html { redirect_to root_path }
        format.json { head :no_content }
      end
    end
  end

  # GET /links/new
  # GET /links/new.json
  def new
    @link = Link.new(project_id: params[:project_id])

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @link }
    end
  end

  # GET /links/1/edit
  def edit
    @project = current_user.all_projects.find_by_id(params[:project_id])
    @link = @project.links.find_by_id(params[:id]) if @project

    respond_to do |format|
      if @project
        format.html # edit.html.erb
        format.json { render json: @link }
      else
        format.html { redirect_to root_path }
        format.json { head :no_content }
      end
    end
  end

  # POST /links
  # POST /links.json
  def create
    @project = current_user.all_projects.find_by_id(params[:project_id])
    @link = @project.links.new(post_params) if @project

    respond_to do |format|
      if @project
        if @link.save
          format.html { redirect_to [@link.project, @link], notice: 'Link was successfully created.' }
          format.json { render json: @link, status: :created, location: @link }
        else
          format.html { render action: "new" }
          format.json { render json: @link.errors, status: :unprocessable_entity }
        end
      else
        format.html { redirect_to root_path }
        format.json { head :no_content }
      end
    end
  end

  # PUT /links/1
  # PUT /links/1.json
  def update
    @project = current_user.all_projects.find_by_id(params[:project_id])
    @link = @project.links.find_by_id(params[:id]) if @project

    respond_to do |format|
      if @project
        if @link.update_attributes(post_params)
          format.html { redirect_to [@link.project, @link], notice: 'Link was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @link.errors, status: :unprocessable_entity }
        end
      else
        format.html { redirect_to root_path }
        format.json { head :no_content }
      end
    end
  end

  # DELETE /links/1
  # DELETE /links/1.json
  def destroy
    @project = current_user.all_projects.find_by_id(params[:project_id])
    @link = @project.links.find_by_id(params[:id]) if @project

    respond_to do |format|
      if @project
        @link.destroy
        format.html { redirect_to project_links_path }
        format.json { head :no_content }
      else
        format.html { redirect_to root_path }
        format.json { head :no_content }
      end
    end
  end

  private

  def post_params
    params[:link] ||= {}

    params[:link][:user_id] = current_user.id

    params[:link].slice(
      :name, :category, :url, :archived, :user_id
    )
  end
end



