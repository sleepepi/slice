# frozen_string_literal: true

# Allows editors to track subject medications.
class MedicationsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_viewable_project_or_redirect, only: [:index, :show]
  before_action :find_editable_project_or_editable_site_or_redirect, only: [
    :new, :edit, :create, :update, :destroy, :review, :still_taking,
    :something_changed, :stopped_completely, :submit_something_changed,
    :change_occurred, :submit_change_occurred, :submit_stopped_completely,
    :autocomplete, :start_review, :continue_review, :review_complete
  ]
  before_action :find_viewable_subject_or_redirect, only: [:index, :show]
  before_action :find_editable_subject_or_redirect, only: [
    :new, :edit, :create, :update, :destroy, :review, :still_taking,
    :something_changed, :stopped_completely, :submit_something_changed,
    :change_occurred, :submit_change_occurred, :submit_stopped_completely,
    :autocomplete, :start_review, :continue_review, :review_complete
  ]
  before_action :find_medication_or_redirect, only: [
    :show, :edit, :update, :destroy, :review, :still_taking,
    :something_changed, :stopped_completely, :submit_something_changed,
    :change_occurred, :submit_change_occurred, :submit_stopped_completely
  ]

  layout "layouts/full_page_sidebar_dark"

  # GET /medications
  def index
    @medications = @subject.medications.page(params[:page]).per(20)
  end

  # # GET /medications/review-complete
  # def review_complete
  # end

  # POST /medications/start-review
  def start_review
    @subject.medications.where(stop_date_fuzzy: nil).order(:id).each_with_index do |medication, index|
      medication.update position: index
    end

    redirect_to next_medication_url
  end

  # POST /medications/continue-review
  def continue_review
    redirect_to next_medication_url
  end

  # # GET /medications/1/review
  # def review
  # end

  # # GET /medications/1
  # def show
  # end

  # POST /medications/1/still-taking
  def still_taking
    @medication.update position: nil
    redirect_to next_medication_url
  end

  # # GET /medications/1/something-changed
  # def something_changed
  # end

  # POST /medications/1/something-changed
  def submit_something_changed
    # TODO: Should create medication (and split) based of the date that this change occurred.
    if @medication.update(medication_params)
      @medication.update position: nil
      redirect_to change_occurred_project_subject_medication_url(@project, @subject, @medication)
    else
      render :something_changed
    end
  end

  # # GET /medications/1/change-occurred
  # def change_occurred
  # end

  # POST /medications/1/change-occurred
  def submit_change_occurred
    # TODO: Update "prior" medication stop date as well
    if @medication.update(medication_params)
      @medication.update position: nil
      redirect_to next_medication_url, notice: "Medication was successfully updated."
    else
      render :change_occurred
    end
  end

  # # GET /medications/1/stopped-completely
  # def stopped_completely
  # end

  # POST /medications/1/stopped-completely
  def submit_stopped_completely
    if @medication.update(medication_params)
      @medication.update position: nil
      redirect_to next_medication_url, notice: "Stop date was successfully updated."
    else
      render :stopped_completely
    end
  end

  # GET /medications/autocomplete.json?medication_variable_id=:medication_variable_id
  def autocomplete
    @medication_variable = @project.medication_variables.find_by(id: params[:medication_variable_id])
  end

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

  def next_medication_url
    medication = @subject.medications.where.not(position: nil).order(:position).first
    if medication
      review_project_subject_medication_path(@project, @subject, medication)
    else
      review_complete_project_subject_medications_path(@project, @subject)
    end
  end

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
