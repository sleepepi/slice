# frozen_string_literal: true

# Allows project editors to add choices to stratification factors on
# randomization schemes.
class StratificationFactorOptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_editable_project_or_redirect
  before_action :redirect_blinded_users
  before_action :find_randomization_scheme_or_redirect
  before_action :find_stratification_factor_or_redirect
  before_action :find_stratification_factor_option_or_redirect,
                only: [:show, :edit, :update, :destroy]
  before_action :redirect_with_published_scheme, only: [:destroy]

  # GET /stratification_factor_options
  def index
    @stratification_factor_options = @stratification_factor
                                     .stratification_factor_options
                                     .order(:value).page(params[:page]).per(40)
  end

  # GET /stratification_factor_options/1
  def show
  end

  # GET /stratification_factor_options/new
  def new
    @stratification_factor_option = @stratification_factor.stratification_factor_options
                                                          .where(
                                                            project_id: @project.id,
                                                            randomization_scheme_id: @randomization_scheme.id,
                                                            user_id: current_user.id
                                                          ).new
  end

  # GET /stratification_factor_options/1/edit
  def edit
  end

  # POST /stratification_factor_options
  def create
    @stratification_factor_option = @stratification_factor.stratification_factor_options
                                                          .where(
                                                            project_id: @project.id,
                                                            randomization_scheme_id: @randomization_scheme.id,
                                                            user_id: current_user.id
                                                          )
                                                          .new(stratification_factor_option_params)
    if @stratification_factor_option.save
      redirect_to(
        [@project, @randomization_scheme, @stratification_factor, @stratification_factor_option],
        notice: 'Stratification factor option was successfully created.'
      )
    else
      render :new
    end
  end

  # PATCH /stratification_factor_options/1
  def update
    if @stratification_factor_option.update(stratification_factor_option_params)
      redirect_to(
        [@project, @randomization_scheme, @stratification_factor, @stratification_factor_option],
        notice: 'Stratification factor option was successfully updated.'
      )
    else
      render :edit
    end
  end

  # DELETE /stratification_factor_options/1
  def destroy
    @stratification_factor_option.destroy
    redirect_to project_randomization_scheme_stratification_factor_stratification_factor_options_path(
      @project, @randomization_scheme, @stratification_factor
    ), notice: 'Stratification factor option was successfully deleted.'
  end

  private

  def find_randomization_scheme_or_redirect
    @randomization_scheme = @project.randomization_schemes.find_by(id: params[:randomization_scheme_id])
    redirect_without_randomization_scheme
  end

  def redirect_without_randomization_scheme
    empty_response_or_root_path(project_randomization_schemes_path(@project)) unless @randomization_scheme
  end

  def find_stratification_factor_or_redirect
    @stratification_factor = @randomization_scheme.stratification_factors.find_by(id: params[:stratification_factor_id])
    redirect_without_stratification_factor
  end

  def redirect_without_stratification_factor
    return if @stratification_factor
    empty_response_or_root_path(
      project_randomization_scheme_stratification_factors_path(@project, @randomization_scheme)
    )
  end

  def find_stratification_factor_option_or_redirect
    @stratification_factor_option = @stratification_factor.stratification_factor_options.find_by(id: params[:id])
    redirect_without_stratification_factor_option
  end

  def redirect_without_stratification_factor_option
    return if @stratification_factor_option
    empty_response_or_root_path(
      project_randomization_scheme_stratification_factor_stratification_factor_options_path(
        @project, @randomization_scheme, @stratification_factor
      )
    )
  end

  def redirect_with_published_scheme
    return unless @randomization_scheme.published?
    flash[:alert] = "Stratification factor options can't be deleted on published randomization scheme."
    empty_response_or_root_path(
      [@project, @randomization_scheme, @stratification_factor, @stratification_factor_option]
    )
  end

  def stratification_factor_option_params
    params.require(:stratification_factor_option).permit(:label, :value)
  end
end
