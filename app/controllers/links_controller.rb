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
  end

  # GET /links/1
  # GET /links/1.json
  def show
  end

  # GET /links/new
  def new
    @link = @project.links.new
  end

  # GET /links/1/edit
  def edit
  end

  # POST /links
  # POST /links.json
  def create
    @link = @project.links.new(link_params)

    respond_to do |format|
      if @link.save
        format.html { redirect_to [@link.project, @link], notice: 'Link was successfully created.' }
        format.json { render action: 'show', status: :created, location: @link }
      else
        format.html { render action: 'new' }
        format.json { render json: @link.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /links/1
  # PUT /links/1.json
  def update
    respond_to do |format|
      if @link.update(link_params)
        format.html { redirect_to [@link.project, @link], notice: 'Link was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
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

    def set_editable_link
      @link = @project.links.find_by_id(params[:id])
    end

    def redirect_without_link
      empty_response_or_root_path(project_links_path) unless @link
    end

    def link_params
      params[:link] ||= {}

      params[:link][:user_id] = current_user.id

      params.require(:link).permit(
        :name, :category, :url, :archived, :user_id
      )
    end

end
