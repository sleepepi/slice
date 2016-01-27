# frozen_string_literal: true

class StratificationFactorsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_editable_project
  before_action :redirect_without_project
  before_action :redirect_blinded_users
  before_action :set_randomization_scheme
  before_action :redirect_without_randomization_scheme
  before_action :set_stratification_factor,               only: [:show, :edit, :update, :destroy]
  before_action :redirect_without_stratification_factor,  only: [:show, :edit, :update, :destroy]
  before_action :redirect_with_published_scheme,          only: [:new, :create, :edit, :update, :destroy]

  # GET /stratification_factors
  # GET /stratification_factors.json
  def index
    @stratification_factors = @randomization_scheme.stratification_factors.order(:name).page(params[:page]).per(40)
  end

  # GET /stratification_factors/1
  # GET /stratification_factors/1.json
  def show
  end

  # GET /stratification_factors/new
  def new
    @stratification_factor = @randomization_scheme.stratification_factors.where(project_id: @project.id, user_id: current_user.id).new
  end

  # GET /stratification_factors/1/edit
  def edit
  end

  # POST /stratification_factors
  # POST /stratification_factors.json
  def create
    @stratification_factor = @randomization_scheme.stratification_factors.where(project_id: @project.id, user_id: current_user.id).new(stratification_factor_params)

    respond_to do |format|
      if @stratification_factor.save
        format.html { redirect_to [@project, @randomization_scheme, @stratification_factor], notice: 'Stratification factor was successfully created.' }
        format.json { render :show, status: :created, location: @stratification_factor }
      else
        format.html { render :new }
        format.json { render json: @stratification_factor.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /stratification_factors/1
  # PATCH/PUT /stratification_factors/1.json
  def update
    respond_to do |format|
      if @stratification_factor.update(stratification_factor_params)
        format.html { redirect_to [@project, @randomization_scheme, @stratification_factor], notice: 'Stratification factor was successfully updated.' }
        format.json { render :show, status: :ok, location: @stratification_factor }
      else
        format.html { render :edit }
        format.json { render json: @stratification_factor.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stratification_factors/1
  # DELETE /stratification_factors/1.json
  def destroy
    @stratification_factor.destroy
    respond_to do |format|
      format.html { redirect_to project_randomization_scheme_stratification_factors_path(@project, @randomization_scheme), notice: 'Stratification factor was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  private
    def set_randomization_scheme
      @randomization_scheme = @project.randomization_schemes.find_by_id(params[:randomization_scheme_id])
    end

    def redirect_without_randomization_scheme
      empty_response_or_root_path(project_randomization_schemes_path(@project)) unless @randomization_scheme
    end

    def set_stratification_factor
      @stratification_factor = @randomization_scheme.stratification_factors.find_by_id(params[:id])
    end

    def redirect_without_stratification_factor
      empty_response_or_root_path(project_randomization_scheme_stratification_factors_path(@project, @randomization_scheme)) unless @stratification_factor
    end

    def redirect_with_published_scheme
      if @randomization_scheme.published?
        flash[:alert] = "Stratification factors can't be created or edited on published randomization scheme."
        empty_response_or_root_path(@stratification_factor ? [@project, @randomization_scheme, @stratification_factor] : project_randomization_scheme_stratification_factors_path(@project, @randomization_scheme))
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def stratification_factor_params
      params.require(:stratification_factor).permit(:name, :stratifies_by_site)
    end
end
