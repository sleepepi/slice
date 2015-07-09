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
  # GET /block_size_multipliers.json
  def index
    @block_size_multipliers = @randomization_scheme.block_size_multipliers.order(:value).page(params[:page]).per(40)
  end

  # GET /block_size_multipliers/1
  # GET /block_size_multipliers/1.json
  def show
  end

  # GET /block_size_multipliers/new
  def new
    @block_size_multiplier = @randomization_scheme.block_size_multipliers.where(project_id: @project.id, user_id: current_user.id).new
  end

  # GET /block_size_multipliers/1/edit
  def edit
  end

  # POST /block_size_multipliers
  # POST /block_size_multipliers.json
  def create
    @block_size_multiplier = @randomization_scheme.block_size_multipliers.where(project_id: @project.id, user_id: current_user.id).new(block_size_multiplier_params)

    respond_to do |format|
      if @block_size_multiplier.save
        format.html { redirect_to [@project, @randomization_scheme, @block_size_multiplier], notice: 'Block size multiplier was successfully created.' }
        format.json { render :show, status: :created, location: @block_size_multiplier }
      else
        format.html { render :new }
        format.json { render json: @block_size_multiplier.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /block_size_multipliers/1
  # PATCH/PUT /block_size_multipliers/1.json
  def update
    respond_to do |format|
      if @block_size_multiplier.update(block_size_multiplier_params)
        format.html { redirect_to [@project, @randomization_scheme, @block_size_multiplier], notice: 'Block size multiplier was successfully updated.' }
        format.json { render :show, status: :ok, location: @block_size_multiplier }
      else
        format.html { render :edit }
        format.json { render json: @block_size_multiplier.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /block_size_multipliers/1
  # DELETE /block_size_multipliers/1.json
  def destroy
    @block_size_multiplier.destroy
    respond_to do |format|
      format.html { redirect_to project_randomization_scheme_block_size_multipliers_path(@project, @randomization_scheme), notice: 'Block size multiplier was successfully destroyed.' }
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

    def set_block_size_multiplier
      @block_size_multiplier = @randomization_scheme.block_size_multipliers.find_by_id(params[:id])
    end

    def redirect_without_block_size_multiplier
      empty_response_or_root_path(project_randomization_scheme_block_size_multipliers_path(@project, @randomization_scheme)) unless @block_size_multiplier
    end

    def redirect_with_published_scheme
      if @randomization_scheme.published?
        flash[:alert] = "Block size multipliers can't be created or edited on published randomization scheme."
        empty_response_or_root_path(@block_size_multiplier ? [@project, @randomization_scheme, @block_size_multiplier] : project_randomization_scheme_block_size_multipliers_path(@project, @randomization_scheme))
      end
    end

    def block_size_multiplier_params
      params[:block_size_multiplier] ||= { blank: '1' }

      params[:block_size_multiplier][:value] = 0 if params[:block_size_multiplier].has_key?(:value) and params[:block_size_multiplier][:value].blank?
      params[:block_size_multiplier][:allocation] = 0 if params[:block_size_multiplier].has_key?(:allocation) and params[:block_size_multiplier][:allocation].blank?

      params.require(:block_size_multiplier).permit(:value, :allocation)
    end
end
