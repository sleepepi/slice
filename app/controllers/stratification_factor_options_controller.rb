class StratificationFactorOptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_editable_project
  before_action :redirect_without_project
  before_action :redirect_blinded_users
  before_action :set_randomization_scheme
  before_action :redirect_without_randomization_scheme
  before_action :set_stratification_factor
  before_action :redirect_without_stratification_factor
  before_action :set_stratification_factor_option,                only: [:show, :edit, :update, :destroy]
  before_action :redirect_without_stratification_factor_option,   only: [:show, :edit, :update, :destroy]
  before_action :redirect_with_published_scheme,                  only: [:destroy]

  # GET /stratification_factor_options
  # GET /stratification_factor_options.json
  def index
    @stratification_factor_options = @stratification_factor.stratification_factor_options.order(:value).page(params[:page]).per(40)
  end

  # GET /stratification_factor_options/1
  # GET /stratification_factor_options/1.json
  def show
  end

  # GET /stratification_factor_options/new
  def new
    @stratification_factor_option = @stratification_factor.stratification_factor_options.where(project_id: @project.id, randomization_scheme_id: @randomization_scheme.id, user_id: current_user.id).new
  end

  # GET /stratification_factor_options/1/edit
  def edit
  end

  # POST /stratification_factor_options
  # POST /stratification_factor_options.json
  def create
    @stratification_factor_option = @stratification_factor.stratification_factor_options.where(project_id: @project.id, randomization_scheme_id: @randomization_scheme.id, user_id: current_user.id).new(stratification_factor_option_params)

    respond_to do |format|
      if @stratification_factor_option.save
        format.html { redirect_to [@project, @randomization_scheme, @stratification_factor, @stratification_factor_option], notice: 'Stratification factor option was successfully created.' }
        format.json { render :show, status: :created, location: @stratification_factor_option }
      else
        format.html { render :new }
        format.json { render json: @stratification_factor_option.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /stratification_factor_options/1
  # PATCH/PUT /stratification_factor_options/1.json
  def update
    respond_to do |format|
      if @stratification_factor_option.update(stratification_factor_option_params)
        format.html { redirect_to [@project, @randomization_scheme, @stratification_factor, @stratification_factor_option], notice: 'Stratification factor option was successfully updated.' }
        format.json { render :show, status: :ok, location: @stratification_factor_option }
      else
        format.html { render :edit }
        format.json { render json: @stratification_factor_option.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stratification_factor_options/1
  # DELETE /stratification_factor_options/1.json
  def destroy
    @stratification_factor_option.destroy
    respond_to do |format|
      format.html { redirect_to project_randomization_scheme_stratification_factor_stratification_factor_options_path(@project, @randomization_scheme, @stratification_factor), notice: 'Stratification factor option was successfully destroyed.' }
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
      @stratification_factor = @randomization_scheme.stratification_factors.find_by_id(params[:stratification_factor_id])
    end

    def redirect_without_stratification_factor
      empty_response_or_root_path(project_randomization_scheme_stratification_factors_path(@project, @randomization_scheme)) unless @stratification_factor
    end

    def set_stratification_factor_option
      @stratification_factor_option = @stratification_factor.stratification_factor_options.find_by_id(params[:id])
    end

    def redirect_without_stratification_factor_option
      empty_response_or_root_path(project_randomization_scheme_stratification_factor_stratification_factor_options_path(@project, @randomization_scheme, @stratification_factor)) unless @stratification_factor_option
    end

    def redirect_with_published_scheme
      if @randomization_scheme.published?
        flash[:alert] = "Stratification factor options can't be deleted on published randomization scheme."
        empty_response_or_root_path([@project, @randomization_scheme, @stratification_factor, @stratification_factor_option])
      end
    end

    def stratification_factor_option_params
      params.require(:stratification_factor_option).permit(:label, :value)
    end
end
