# frozen_string_literal: true

# Allows project editors to modify domain options.
class DomainOptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_editable_project_or_redirect
  before_action :find_domain_or_redirect
  before_action :find_domain_option_or_redirect, only: [:show, :edit, :update, :destroy]

  # GET /domains/1/options
  def index
    @domain_options = @domain.domain_options.order(:value).page(params[:page]).per(40)
  end

  # # GET /domains/1/options/1
  # def show
  # end

  # GET /domains/1/options/new
  def new
    @domain_option = @domain.domain_options.new
  end

  # # GET /domains/1/options/1/edit
  # def edit
  # end

  # POST /domains/1/options
  def create
    @domain_option = @domain.domain_options.new(domain_option_params)
    if @domain_option.save
      @domain_option.add_domain_option!
      redirect_to [@project, @domain, @domain_option], notice: "Domain option was successfully created."
    else
      render :new
    end
  end

  # PATCH /domains/1/options/1
  def update
    if @domain_option.update(domain_option_params)
      @domain_option.add_domain_option!
      redirect_to [@project, @domain, @domain_option], notice: "Domain option was successfully updated."
    else
      render :edit
    end
  end

  # DELETE /domains/1/options/1
  def destroy
    @domain_option.destroy
    redirect_to project_domain_domain_options_path(@project, @domain), notice: "Domain option was successfully deleted."
  end

  private

  def find_domain_or_redirect
    @domain = @project.domains.find_by(id: params[:domain_id])
    redirect_without_domain
  end

  def redirect_without_domain
    empty_response_or_root_path(project_domains_path(@project)) unless @domain
  end

  def find_domain_option_or_redirect
    @domain_option = @domain.domain_options.find_by(id: params[:id])
    redirect_without_domain_option
  end

  def redirect_without_domain_option
    empty_response_or_root_path([@project, @domain]) unless @domain_option
  end

  def domain_option_params
    params.require(:domain_option).permit(
      :name, :value, :description, :site_id, :missing_code, :mutually_exclusive,
      :archived
    )
  end
end
