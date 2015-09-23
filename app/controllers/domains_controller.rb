class DomainsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_editable_project, only: [:index, :show, :new, :edit, :create, :update, :destroy, :values]
  before_action :redirect_without_project, only: [:index, :show, :new, :edit, :create, :update, :destroy, :values]
  before_action :set_editable_domain, only: [:show, :edit, :update, :destroy]
  before_action :redirect_without_domain, only: [:show, :edit, :update, :destroy]

  def values
    @domain = @project.domains.find_by_id params[:domain_id]
  end

  def add_option
  end

  # GET /domains
  def index
    @order = scrub_order(Domain, params[:order], 'domains.name')
    @domains = @project.domains.search(params[:search]).order(@order).page(params[:page]).per(20)
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
  def create
    @domain = @project.domains.new(domain_params)
    if @domain.save
      url = if params[:continue].to_s == '1'
              new_project_domain_path(@domain.project)
            else
              [@domain.project, @domain]
            end
      redirect_to url, notice: 'Domain was successfully created.'
    else
      render :new
    end
  end

  # PUT /domains/1
  # PUT /domains/1.json
  def update
    if @domain.update(domain_params)
      url = if params[:continue].to_s == '1'
              new_project_domain_path(@domain.project)
            else
              [@domain.project, @domain]
            end
      redirect_to url, notice: 'Domain was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /domains/1
  def destroy
    @domain.destroy
    redirect_to project_domains_path(@project)
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

    # Always update user_id to correctly track sheet transactions
    params[:domain][:user_id] = current_user.id # unless @domain

    params[:domain] = Domain.clean_option_tokens(params[:domain])

    params.require(:domain).permit(
      :name, :display_name, :description, :user_id, { option_tokens: [:name, :value, :description, :missing_code, :option_index] }
    )
  end
end
