class DomainsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_editable_project, only: [ :index, :show, :new, :edit, :create, :update, :destroy, :values ]
  before_action :redirect_without_project, only: [ :index, :show, :new, :edit, :create, :update, :destroy, :values ]
  before_action :set_editable_domain, only: [ :show, :edit, :update, :destroy ]
  before_action :redirect_without_domain, only: [ :show, :edit, :update, :destroy ]

  def values
    @domain = @project.domains.find_by_id(params[:domain_id])
  end

  def add_option

  end

  # GET /domains
  # GET /domains.json
  def index
    @order = scrub_order(Domain, params[:order], "domains.name")
    @domains = @project.domains.search(params[:search]).order(@order).page(params[:page]).per( 20 )
  end

  # GET /domains/1
  # GET /domains/1.json
  def show
  end

  # GET /domains/new
  def new
    @domain = @project.domains.new
  end

  # GET /domains/1/edit
  def edit
  end

  # POST /domains
  # POST /domains.json
  def create
    @domain = @project.domains.new(domain_params)

    respond_to do |format|
      if @domain.save
        format.html { redirect_to [@domain.project, @domain], notice: 'Domain was successfully created.' }
        format.json { render action: 'show', status: :created, location: @domain }
      else
        format.html { render action: 'new' }
        format.json { render json: @domain.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /domains/1
  # PUT /domains/1.json
  def update
    respond_to do |format|
      if @domain.update(domain_params)
        format.html { redirect_to [@domain.project, @domain], notice: 'Domain was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @domain.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /domains/1
  # DELETE /domains/1.json
  def destroy
    @domain.destroy

    respond_to do |format|
      format.html { redirect_to project_domains_path(@project) }
      format.json { head :no_content }
    end
  end

  private

    def set_editable_domain
      @domain = @project.domains.find_by_id(params[:id])
    end

    def redirect_without_domain
      empty_response_or_root_path(project_domains_path(@project)) unless @domain
    end

    def domain_params
      params[:domain] ||= {}

      params[:domain][:user_id] = current_user.id unless @domain

      params.require(:domain).permit(
        :name, :description, :user_id, { :option_tokens => [ :name, :value, :description, :missing_code, :color, :option_index ] }
      )
    end

end
