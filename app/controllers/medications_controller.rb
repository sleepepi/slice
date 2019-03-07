# frozen_string_literal: true

# Allows editors to track subject medications.
class MedicationsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_viewable_project_or_redirect, only: [:index, :show]
  before_action :find_editable_project_or_editable_site_or_redirect, only: [
    :new, :edit, :create, :update, :destroy
  ]
  before_action :find_viewable_subject_or_redirect, only: [:index, :show]
  before_action :find_editable_subject_or_redirect, only: [
    :new, :edit, :create, :update, :destroy
  ]
  before_action :find_medication_or_redirect, only: [
    :show, :edit, :update, :destroy
  ]

  layout "layouts/full_page_sidebar_dark"

  # GET /medications
  def index
    @medications = @subject.medications.page(params[:page]).per(20)
  end

  # # GET /medications/1
  # def show
  # end

  # GET /medications/new
  def new
    @medication = @subject.medications.where(project: @project).new
  end

  # # GET /medications/1/edit
  # def edit
  # end

  # POST /medications
  def create
    @medication = @subject.medications.where(project: @project).new(medication_params)
    if @medication.save
      @medication.save_medication_variables!
      redirect_to [@project, @subject, @medication], notice: "Medication was successfully created."
    else
      render :new
    end
  end

  # PATCH /medications/1
  def update
    if @medication.update(medication_params)
      @medication.save_medication_variables!
      redirect_to [@project, @subject, @medication], notice: "Medication was successfully updated."
    else
      render :edit
    end
  end

  # DELETE /medications/1
  def destroy
    @medication.destroy
    redirect_to project_subject_medications_path(@project, @subject), notice: "Medication was successfully destroyed."
  end

  private

  def find_medication_or_redirect
    @medication = @subject.medications.find_by(id: params[:id])
    empty_response_or_root_path(project_subject_medications_path(@project, @subject)) unless @medication
  end

  def medication_params
    params.require(:medication).permit(
      :position, :name,
      :start_date_fuzzy_edit, :stop_date_fuzzy_edit,
      :start_date_fuzzy_mo_1, :start_date_fuzzy_mo_2,
      :start_date_fuzzy_dy_1, :start_date_fuzzy_dy_2,
      :start_date_fuzzy_yr_1, :start_date_fuzzy_yr_2,
      :start_date_fuzzy_yr_3, :start_date_fuzzy_yr_4,
      :stop_date_fuzzy_mo_1, :stop_date_fuzzy_mo_2,
      :stop_date_fuzzy_dy_1, :stop_date_fuzzy_dy_2,
      :stop_date_fuzzy_yr_1, :stop_date_fuzzy_yr_2,
      :stop_date_fuzzy_yr_3, :stop_date_fuzzy_yr_4,
      medication_variables: {}
    )
  end
end
