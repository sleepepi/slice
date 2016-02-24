# frozen_string_literal: true

# Allows project editors to view and modify treatment arms
class TreatmentArmsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_editable_project
  before_action :redirect_without_project
  before_action :redirect_blinded_users
  before_action :set_randomization_scheme
  before_action :redirect_without_randomization_scheme
  before_action :set_treatment_arm,               only: [:show, :edit, :update, :destroy]
  before_action :redirect_with_published_scheme,  only: [:new, :create, :edit, :update, :destroy]

  # GET /treatment_arms
  def index
    @treatment_arms = @randomization_scheme.treatment_arms.order(:name).page(params[:page]).per(40)
  end

  # GET /treatment_arms/1
  def show
  end

  # GET /treatment_arms/new
  def new
    @treatment_arm = @randomization_scheme.treatment_arms
                                          .where(project_id: @project.id, user_id: current_user.id)
                                          .new
  end

  # GET /treatment_arms/1/edit
  def edit
  end

  # POST /treatment_arms
  def create
    @treatment_arm = @randomization_scheme.treatment_arms
                                          .where(project_id: @project.id, user_id: current_user.id)
                                          .new(treatment_arm_params)
    if @treatment_arm.save
      redirect_to [@project, @randomization_scheme, @treatment_arm], notice: 'Treatment arm was successfully created.'
    else
      render :new
    end
  end

  # PATCH /treatment_arms/1
  def update
    if @treatment_arm.update(treatment_arm_params)
      redirect_to [@project, @randomization_scheme, @treatment_arm], notice: 'Treatment arm was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /treatment_arms/1
  def destroy
    @treatment_arm.destroy
    redirect_to project_randomization_scheme_treatment_arms_path(@project, @randomization_scheme), notice: 'Treatment arm was successfully deleted.'
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
    empty_response_or_root_path(project_randomization_scheme_treatment_arms_path(@project, @randomization_scheme)) unless @treatment_arm
  end

  def redirect_with_published_scheme
    if @randomization_scheme.published?
      flash[:alert] = "Treatment arms can't be created or edited on published randomization scheme."
      empty_response_or_root_path(@treatment_arm ? [@project, @randomization_scheme, @treatment_arm] : project_randomization_scheme_treatment_arms_path(@project, @randomization_scheme))
    end
  end

  def treatment_arm_params
    params[:treatment_arm] ||= { blank: '1' }
    params[:treatment_arm][:allocation] = 0 if params[:treatment_arm].key?(:allocation) && params[:treatment_arm][:allocation].blank?
    params.require(:treatment_arm).permit(:name, :allocation)
  end
end
