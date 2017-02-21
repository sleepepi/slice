# frozen_string_literal: true

# Allows variable value domains to be viewed and created by project editors.
class DomainsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_editable_project_or_redirect
  before_action :find_domain_or_redirect,
                only: [:show, :edit, :update, :destroy]

  # TODO: Check to see where domains/values is called from and if it can be
  # removed.
  # POST /domains/values.js
  def values
    @domain = @project.domains.find_by(id: params[:domain_id])
  end

  # POST /domains/add_option.js
  def add_option
    @domain_options = (0..2).collect { DomainOption.new }
  end

  # GET /domains
  def index
    @order = scrub_order(Domain, params[:order], 'domains.name')
    @domains = @project.domains.search(params[:search], match_start: false)
                       .order(@order).page(params[:page]).per(20)
  end

  # GET /domains/1
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
      @domain.update_option_tokens!
      redirect_to show_or_continue, notice: 'Domain was successfully created.'
    else
      render :new
    end
  end

  # PATCH /domains/1
  def update
    if @domain.update(domain_params)
      @domain.update_option_tokens!
      redirect_to show_or_continue, notice: 'Domain was successfully updated.'
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

  def find_domain_or_redirect
    @domain = @project.domains.find_by(id: params[:id])
    redirect_without_domain
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
      :name, :display_name, :description, :user_id,
      option_tokens: [:name, :value, :description, :missing_code, :site_id, :domain_option_id, :archived]
    )
  end

  def show_or_continue
    if params[:continue].to_s == '1'
      new_project_domain_path(@project)
    else
      [@project, @domain]
    end
  end
end
