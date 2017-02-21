# frozen_string_literal: true

# Allows project editors to specify block size multipliers for randomization
# schemes using the permuted-block algorithm.
class BlockSizeMultipliersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_editable_project
  before_action :redirect_without_project
  before_action :set_randomization_scheme
  before_action :redirect_without_randomization_scheme

  before_action :set_block_size_multiplier,               only: [:show, :edit, :update, :destroy]
  before_action :redirect_without_block_size_multiplier,  only: [:show, :edit, :update, :destroy]
  before_action :redirect_with_published_scheme,          only: [:new, :create, :edit, :update, :destroy]

  # GET /block_size_multipliers
  def index
    @block_size_multipliers = @randomization_scheme.block_size_multipliers.order(:value).page(params[:page]).per(40)
  end

  # GET /block_size_multipliers/1
  def show
  end

  # GET /block_size_multipliers/new
  def new
    @block_size_multiplier = block_size_multipliers.new
  end

  # GET /block_size_multipliers/1/edit
  def edit
  end

  # POST /block_size_multipliers
  def create
    @block_size_multiplier = block_size_multipliers.new(block_size_multiplier_params)

    if @block_size_multiplier.save
      message = 'Block size multiplier was successfully created.'
      redirect_to [@project, @randomization_scheme, @block_size_multiplier], notice: message
    else
      render :new
    end
  end

  # PATCH /block_size_multipliers/1
  def update
    if @block_size_multiplier.update(block_size_multiplier_params)
      message = 'Block size multiplier was successfully updated.'
      redirect_to [@project, @randomization_scheme, @block_size_multiplier], notice: message
    else
      render :edit
    end
  end

  # DELETE /block_size_multipliers/1
  def destroy
    @block_size_multiplier.destroy
    redirect_to project_randomization_scheme_block_size_multipliers_path(@project, @randomization_scheme),
                notice: 'Block size multiplier was successfully deleted.'
  end

  private

  def block_size_multipliers
    @randomization_scheme.block_size_multipliers.where(project_id: @project.id, user_id: current_user.id)
  end

  def set_randomization_scheme
    @randomization_scheme = @project.randomization_schemes.find_by(id: params[:randomization_scheme_id])
  end

  def redirect_without_randomization_scheme
    empty_response_or_root_path(project_randomization_schemes_path(@project)) unless @randomization_scheme
  end

  def set_block_size_multiplier
    @block_size_multiplier = @randomization_scheme.block_size_multipliers.find_by(id: params[:id])
  end

  def redirect_without_block_size_multiplier
    redirect_path = project_randomization_scheme_block_size_multipliers_path(@project, @randomization_scheme)
    empty_response_or_root_path(redirect_path) unless @block_size_multiplier
  end

  def redirect_with_published_scheme
    if @randomization_scheme.published?
      flash[:alert] = "Block size multipliers can't be created or edited on published randomization scheme."
      redirect_path = if @block_size_multiplier
                        [@project, @randomization_scheme, @block_size_multiplier]
                      else
                        project_randomization_scheme_block_size_multipliers_path(@project, @randomization_scheme)
                      end
      empty_response_or_root_path(redirect_path)
    end
  end

  def block_size_multiplier_params
    params[:block_size_multiplier] ||= { blank: '1' }
    check_key_and_set_default_value(:block_size_multiplier, :value, 1)
    check_key_and_set_default_value(:block_size_multiplier, :allocation, 0)
    params.require(:block_size_multiplier).permit(:value, :allocation)
  end
end
