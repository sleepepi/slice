class DomainsController < ApplicationController
  before_filter :authenticate_user!

  def add_option

  end

  # GET /domains
  # GET /domains.json
  def index
    @project = current_user.all_projects.find_by_id(params[:project_id])

    if @project
      domain_scope = @project.domains.scoped()
      @order = scrub_order(Domain, params[:order], "domains.name")
      domain_scope = domain_scope.order(@order)
      @domain_count = domain_scope.count
      @domains = domain_scope.page(params[:page]).per( 20 )
    end

    respond_to do |format|
      if @project
        format.html # index.html.erb
        format.js
        format.json { render json: @domains }
      else
        format.html { redirect_to root_path }
        format.json { head :no_content }
      end
    end
  end

  # GET /domains/1
  # GET /domains/1.json
  def show
    @project = current_user.all_projects.find_by_id(params[:project_id])
    @domain = @project.domains.find_by_id(params[:id]) if @project

    respond_to do |format|
      if @project
        format.html # show.html.erb
        format.json { render json: @domain }
      else
        format.html { redirect_to root_path }
        format.json { head :no_content }
      end
    end
  end

  # GET /domains/new
  # GET /domains/new.json
  def new
    @domain = Domain.new(project_id: params[:project_id])

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @domain }
    end
  end

  # GET /domains/1/edit
  def edit
    @project = current_user.all_projects.find_by_id(params[:project_id])
    @domain = @project.domains.find_by_id(params[:id]) if @project

    respond_to do |format|
      if @project
        format.html # edit.html.erb
        format.json { render json: @domain }
      else
        format.html { redirect_to root_path }
        format.json { head :no_content }
      end
    end
  end

  # POST /domains
  # POST /domains.json
  def create
    @project = current_user.all_projects.find_by_id(params[:project_id])
    @domain = @project.domains.new(post_params) if @project

    respond_to do |format|
      if @project
        if @domain.save
          format.html { redirect_to [@domain.project, @domain], notice: 'Domain was successfully created.' }
          format.json { render json: @domain, status: :created, location: @domain }
        else
          format.html { render action: "new" }
          format.json { render json: @domain.errors, status: :unprocessable_entity }
        end
      else
        format.html { redirect_to root_path }
        format.json { head :no_content }
      end
    end
  end

  # PUT /domains/1
  # PUT /domains/1.json
  def update
    @project = current_user.all_projects.find_by_id(params[:project_id])
    @domain = @project.domains.find_by_id(params[:id]) if @project

    respond_to do |format|
      if @project
        if @domain.update_attributes(post_params)
          format.html { redirect_to [@domain.project, @domain], notice: 'Domain was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @domain.errors, status: :unprocessable_entity }
        end
      else
        format.html { redirect_to root_path }
        format.json { head :no_content }
      end
    end
  end

  # DELETE /domains/1
  # DELETE /domains/1.json
  def destroy
    @project = current_user.all_projects.find_by_id(params[:project_id])
    @domain = @project.domains.find_by_id(params[:id]) if @project

    respond_to do |format|
      if @project
        @domain.destroy
        format.html { redirect_to project_domains_path }
        format.json { head :no_content }
      else
        format.html { redirect_to root_path }
        format.json { head :no_content }
      end
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
end
