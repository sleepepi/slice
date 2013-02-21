class DomainsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :set_editable_project, only: [ :index, :show, :new, :edit, :create, :update, :destroy ]
  before_filter :redirect_without_project, only: [ :index, :show, :new, :edit, :create, :update, :destroy ]
  before_filter :set_editable_domain, only: [ :show, :edit, :update, :destroy ]
  before_filter :redirect_without_domain, only: [ :show, :edit, :update, :destroy ]

  def values
    @project = current_user.all_projects.find_by_id(params[:project_id])
    @domain = @project.domains.find_by_id(params[:domain_id])
  end

  def add_option

  end

  # GET /domains
  # GET /domains.json
  def index
    @order = scrub_order(Domain, params[:order], "domains.name")
    @domains = @project.domains.search(params[:search]).order(@order).page(params[:page]).per( 20 )

    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.json { render json: @domains }
    end
  end

  # GET /domains/1
  # GET /domains/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @domain }
    end
  end

  # GET /domains/new
  # GET /domains/new.json
  def new
    @domain = @project.domains.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @domain }
    end
  end

  # GET /domains/1/edit
  def edit
    respond_to do |format|
      format.html # edit.html.erb
      format.json { render json: @domain }
    end
  end

  # POST /domains
  # POST /domains.json
  def create
    @domain = @project.domains.new(post_params)

    respond_to do |format|
      if @domain.save
        format.html { redirect_to [@domain.project, @domain], notice: 'Domain was successfully created.' }
        format.json { render json: @domain, status: :created, location: @domain }
      else
        format.html { render action: "new" }
        format.json { render json: @domain.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /domains/1
  # PUT /domains/1.json
  def update
    respond_to do |format|
      if @domain.update_attributes(post_params)
        format.html { redirect_to [@domain.project, @domain], notice: 'Domain was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @domain.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /domains/1
  # DELETE /domains/1.json
  def destroy
    respond_to do |format|
      @domain.destroy
      format.html { redirect_to project_domains_path }
      format.json { head :no_content }
    end
  end

  private

  def post_params
    params[:domain] ||= {}

    params[:domain][:user_id] = current_user.id

    params[:domain].slice(
      :name, :description, :option_tokens, :user_id
    )
  end

  def set_editable_domain
    @domain = @project.domains.find_by_id(params[:id])
  end

  def redirect_without_domain
    empty_response_or_root_path(project_domains_path) unless @domain
  end

end
