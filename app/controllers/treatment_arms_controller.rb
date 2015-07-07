class TreatmentArmsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_editable_project
  before_action :redirect_without_project
  before_action :set_randomization_scheme
  before_action :redirect_without_randomization_scheme

  before_action :set_treatment_arm,               only: [:show, :edit, :update, :destroy]
  before_action :redirect_without_treatment_arm,  only: [:show, :edit, :update, :destroy]

  # GET /treatment_arms
  # GET /treatment_arms.json
  def index
    @treatment_arms = @randomization_scheme.treatment_arms.order(:name).page(params[:page]).per(40)
  end

  # GET /treatment_arms/1
  # GET /treatment_arms/1.json
  def show
  end

  # GET /treatment_arms/new
  def new
    @treatment_arm = @randomization_scheme.treatment_arms.where(project_id: @project.id, user_id: current_user.id).new
  end

  # GET /treatment_arms/1/edit
  def edit
  end

  # POST /treatment_arms
  # POST /treatment_arms.json
  def create
    @treatment_arm = @randomization_scheme.treatment_arms.where(project_id: @project.id, user_id: current_user.id).new(treatment_arm_params)

    respond_to do |format|
      if @treatment_arm.save
        format.html { redirect_to [@project, @randomization_scheme, @treatment_arm], notice: 'Treatment arm was successfully created.' }
        format.json { render :show, status: :created, location: @treatment_arm }
      else
        format.html { render :new }
        format.json { render json: @treatment_arm.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /treatment_arms/1
  # PATCH/PUT /treatment_arms/1.json
  def update
    respond_to do |format|
      if @treatment_arm.update(treatment_arm_params)
        format.html { redirect_to [@project, @randomization_scheme, @treatment_arm], notice: 'Treatment arm was successfully updated.' }
        format.json { render :show, status: :ok, location: @treatment_arm }
      else
        format.html { render :edit }
        format.json { render json: @treatment_arm.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /treatment_arms/1
  # DELETE /treatment_arms/1.json
  def destroy
    @treatment_arm.destroy
    respond_to do |format|
      format.html { redirect_to project_randomization_scheme_treatment_arms_path(@project, @randomization_scheme), notice: 'Treatment arm was successfully destroyed.' }
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

    def set_treatment_arm
      @treatment_arm = @randomization_scheme.treatment_arms.find_by_id(params[:id])
    end

    def redirect_without_treatment_arm
      empty_response_or_root_path(project_treatment_arms_path(@project, @randomization_scheme)) unless @treatment_arm
    end

    def treatment_arm_params
      params[:treatment_arm] ||= { blank: '1' }

      params[:treatment_arm][:allocation] = 0 if params[:treatment_arm].has_key?(:allocation) and params[:treatment_arm][:allocation].blank?

      params.require(:treatment_arm).permit(:name, :allocation)
    end
end
