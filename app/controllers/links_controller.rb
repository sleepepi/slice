class LinksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_editable_project, only: [ :index, :show, :new, :edit, :create, :update, :destroy ]
  before_action :redirect_without_project, only: [ :index, :show, :new, :edit, :create, :update, :destroy ]
  before_action :set_editable_link, only: [ :show, :edit, :update, :destroy ]
  before_action :redirect_without_link, only: [ :show, :edit, :update, :destroy ]

  # GET /links
  # GET /links.json
  def index
    @order = scrub_order(Link, params[:order], "links.name")
    @links = @project.links.search(params[:search]).order(@order).page(params[:page]).per( 20 )

    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.json { render json: @links }
    end
  end

  # GET /links/1
  # GET /links/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @link }
    end
  end

  # GET /links/new
  # GET /links/new.json
  def new
    @link = @project.links.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @link }
    end
  end

  # GET /links/1/edit
  def edit
    respond_to do |format|
      format.html # edit.html.erb
      format.json { render json: @link }
    end
  end

  # POST /links
  # POST /links.json
  def create
    @link = @project.links.new(post_params)

    respond_to do |format|
      if @link.save
        format.html { redirect_to [@link.project, @link], notice: 'Link was successfully created.' }
        format.json { render json: @link, status: :created, location: @link }
      else
        format.html { render action: "new" }
        format.json { render json: @link.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /links/1
  # PUT /links/1.json
  def update
    respond_to do |format|
      if @link.update_attributes(post_params)
        format.html { redirect_to [@link.project, @link], notice: 'Link was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @link.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /links/1
  # DELETE /links/1.json
  def destroy
    @link.destroy

    respond_to do |format|
      format.html { redirect_to project_links_path }
      format.json { head :no_content }
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

  def set_editable_link
    @link = @project.links.find_by_id(params[:id])
  end

  def redirect_without_link
    empty_response_or_root_path(project_links_path) unless @link
  end
end
