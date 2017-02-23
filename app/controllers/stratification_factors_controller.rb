# frozen_string_literal: true

# Allows stratification factors to be created and set for a specific
# randomization scheme.
class StratificationFactorsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_editable_project_or_redirect
  before_action :redirect_blinded_users
  before_action :find_randomization_scheme_or_redirect
  before_action :find_stratification_factor_or_redirect, only: [:show, :edit, :update, :destroy]
  before_action :redirect_with_published_scheme, only: [:new, :create, :edit, :update, :destroy]

  # GET /stratification_factors
  def index
    @stratification_factors = @randomization_scheme.stratification_factors.order(:name).page(params[:page]).per(40)
  end

  # # GET /stratification_factors/1
  # def show
  # end

  # GET /stratification_factors/new
  def new
    @stratification_factor = @randomization_scheme.stratification_factors
                                                  .where(project_id: @project.id, user_id: current_user.id).new
  end

  # # GET /stratification_factors/1/edit
  # def edit
  # end

  # POST /stratification_factors
  def create
    @stratification_factor = @randomization_scheme.stratification_factors
                                                  .where(project_id: @project.id, user_id: current_user.id)
                                                  .new(stratification_factor_params)
    if @stratification_factor.save
      redirect_to(
        [@project, @randomization_scheme, @stratification_factor],
        notice: 'Stratification factor was successfully created.'
      )
    else
      render :new
    end
  end

  # PATCH /stratification_factors/1
  def update
    if @stratification_factor.update(stratification_factor_params)
      redirect_to(
        [@project, @randomization_scheme, @stratification_factor],
        notice: 'Stratification factor was successfully updated.'
      )
    else
      render :edit
    end
  end

  # DELETE /stratification_factors/1
  def destroy
    @stratification_factor.destroy
    redirect_to(
      project_randomization_scheme_stratification_factors_path(@project, @randomization_scheme),
      notice: 'Stratification factor was successfully deleted.'
    )
  end

  private

  def find_randomization_scheme_or_redirect
    @randomization_scheme = @project.randomization_schemes.find_by(id: params[:randomization_scheme_id])
    redirect_without_randomization_scheme
  end

  def redirect_without_randomization_scheme
    return if @randomization_scheme
    empty_response_or_root_path(project_randomization_schemes_path(@project))
  end

  def find_stratification_factor_or_redirect
    @stratification_factor = @randomization_scheme.stratification_factors.find_by(id: params[:id])
    redirect_without_stratification_factor
  end

  def redirect_without_stratification_factor
    return if @stratification_factor
    empty_response_or_root_path(
      project_randomization_scheme_stratification_factors_path(@project, @randomization_scheme)
    )
  end

  def redirect_with_published_scheme
    return unless @randomization_scheme.published?
    flash[:alert] = "Stratification factors can't be created or edited on published randomization scheme."
    url = if @stratification_factor
            [@project, @randomization_scheme, @stratification_factor]
          else
            project_randomization_scheme_stratification_factors_path(@project, @randomization_scheme)
          end
    empty_response_or_root_path(url)
  end

  def stratification_factor_params
    params[:stratification_factor] ||= { blank: '1' }
    clean_calculation
    params.require(:stratification_factor).permit(:name, :stratifies_by_site, :calculation)
  end

  def clean_calculation
    return unless params[:stratification_factor].key?(:calculation)
    params[:stratification_factor][:calculation] = params[:stratification_factor][:calculation].to_s.strip
  end
end
