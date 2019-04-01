# frozen_string_literal: true

# Allows project editors to define randomization schemes based on permuted-block
# or minimization algorithms.
class RandomizationSchemesController < ApplicationController
  before_action :authenticate_user!
  before_action :find_editable_project_or_editable_site_or_redirect, only: [
    :randomize_subject, :subject_search, :randomize_subject_to_list
  ]
  before_action :find_editable_project_or_redirect, only: [
    :add_task, :index, :show, :new, :edit, :create, :update, :destroy, :publish,
    :unpublish, :edit_randomization, :update_randomization,
    :destroy_randomization
  ]
  before_action :redirect_blinded_users
  before_action :find_scheme_or_redirect, only: [
    :show, :edit, :update, :destroy, :publish, :unpublish,
    :edit_randomization, :update_randomization, :destroy_randomization
  ]
  before_action :find_published_scheme_or_redirect, only: [
    :randomize_subject, :subject_search, :randomize_subject_to_list, :unpublish
  ]
  before_action :find_randomization_or_redirect, only: [
    :edit_randomization, :update_randomization, :destroy_randomization
  ]

  layout "layouts/full_page_sidebar_dark"

  # # POST /template/add_task.js
  # def add_task
  # end

  # GET /schemes/1/randomize-subject
  def randomize_subject
    @randomization = @project.randomizations.where(randomization_scheme_id: @randomization_scheme).new
    if params[:subject_code].present? && params[:stratification_factors].blank?
      @subject = @project.subjects.find_by(subject_code: params[:subject_code])
      params[:stratification_factors] = @subject.stratification_factors_for_params(@randomization_scheme) if @subject
    end
  end

  # GET /schemes/1/subject_search
  def subject_search
    @subjects = current_user.all_viewable_subjects.where(project_id: @project.id)
                            .search_any_order(params[:q]).order(:subject_code).limit(5)

    result = @subjects.collect do |s|
      status = "E"
      status_class = "default"
      randomized = (s.randomizations.where(randomization_scheme_id: @randomization_scheme.id).count == 1)
      if @randomization_scheme.variable
        unless s.has_value?(@randomization_scheme.variable, @randomization_scheme.variable_value)
          # Subject Ineligible for Randomization
          status = "I"
          status_class = "danger"
        end
      end
      if randomized
        status = "R"
        status_class = "primary"
      end

      stratification_factors = s.stratification_factors(@randomization_scheme)

      { value: s.subject_code, subject_code: s.subject_code, status_class: status_class,
        status: status, site_id: s.site_id, stratification_factors: stratification_factors }
    end

    if @subjects.present?
      render json: result
    else
      render json: [{ value: params[:q], subject_code: "Subject Not Found", status_class: "default", status: "", site_id: nil, stratification_factors: [] }]
    end
  end

  # POST /schemes/1/randomize-subject
  def randomize_subject_to_list
    @randomization = @project.randomizations.where(randomization_scheme_id: @randomization_scheme).new

    subject = current_user.all_subjects.where(project_id: @project.id)
                          .where("LOWER(subjects.subject_code) = ?", params[:subject_code].to_s.downcase).first

    if @randomization_scheme.lists.count == 0
      @randomization.errors.add(:lists, "need to be generated before a subject can be randomized")
      render :randomize_subject
      return
    end

    unless subject
      @randomization.errors.add(:subject_code, "does not match an existing subject")
      render :randomize_subject
      return
    end

    if @randomization_scheme.variable && !subject.has_value?(@randomization_scheme.variable, @randomization_scheme.variable_value)
      variable_message = "#{@randomization_scheme.variable.display_name} is not equal to #{@randomization_scheme.variable_value}"
      @randomization.errors.add(:subject_id, "is ineligible for randomization due to variable criteria")
      @randomization.errors.add(:subject_id, variable_message)
      render :randomize_subject
      return
    end

    criteria_pairs = build_criteria_pairs
    list = @randomization_scheme.find_list_by_criteria_pairs(criteria_pairs)

    invalid_criteria_found = false

    unless list && @randomization_scheme.all_criteria_selected?(criteria_pairs)
      @randomization.errors.add(:stratification_factors, "can't be blank")
      invalid_criteria_found = true
    end

    expected_stratification_factors = subject.stratification_factors(@randomization_scheme)

    @randomization_scheme.stratification_factors_with_calculation.each do |sf|
      criteria_pair = criteria_pairs.find { |sfid, _oid| sfid == sf.id }
      sfo = sf.stratification_factor_options.find_by(id: criteria_pair.last) if criteria_pair
      unless sfo && sfo.value.to_s == expected_stratification_factors[sf.id.to_s].to_s
        @randomization.errors.add(sf.name, "does not match value specified on subject sheet")
        invalid_criteria_found = true
      end
    end

    if invalid_criteria_found
      render :randomize_subject
      return
    end

    stratification_factor = @randomization_scheme.stratification_factors.where(stratifies_by_site: true).first

    if stratification_factor
      if subject.site_id.to_i != (params[:stratification_factors] || {})[stratification_factor.id.to_s.to_sym].to_i
        @randomization.errors.add(:subject_id, "must be randomized to their site")
        render :randomize_subject
        return
      end
    end

    if params[:attested] != "1"
      @randomization.errors.add(:attested, "must be checked")
      render :randomize_subject
      return
    end

    @randomization = @randomization_scheme.randomize_subject_to_list!(subject, list, current_user, criteria_pairs)

    if @randomization && @randomization.errors.full_messages == []
      @randomization.launch_tasks!
      @randomization.generate_name!

      redirect_to [@project, @randomization],
                  notice: "Subject successfully randomized to #{@randomization.treatment_arm_name}."
    elsif @randomization
      @randomization.errors.delete(:subject_id)
      @randomization.errors.add(:subject_id, "has already been randomized")
      render :randomize_subject
    else
      redirect_to choose_scheme_project_randomizations_path(@project),
                  alert: "Subject was NOT successfully randomized. #{@randomization_scheme.randomization_error_message}"
    end
  end

  # GET /schemes
  def index
    @order = scrub_order(RandomizationScheme, params[:order], "randomization_schemes.name")
    @randomization_schemes = @project.randomization_schemes
                                     .order(@order)
                                     .page(params[:page]).per(40)
  end

  # # GET /schemes/1
  # def show
  # end

  # GET /schemes/new
  def new
    @randomization_scheme = current_user.randomization_schemes.where(project_id: @project.id).new
  end

  # # GET /schemes/1/edit
  # def edit
  # end

  # POST /schemes
  def create
    @randomization_scheme = current_user.randomization_schemes.where(project_id: @project.id)
                                        .new(randomization_scheme_params)
    if @randomization_scheme.save
      redirect_to [@project, @randomization_scheme], notice: "Randomization scheme was successfully created."
    else
      render :new
    end
  end

  # PATCH /schemes/1
  def update
    if @randomization_scheme.update(randomization_scheme_params)
      redirect_to [@project, @randomization_scheme], notice: "Randomization scheme was successfully updated."
    else
      render :edit
    end
  end

  # POST /schemes/1/publish
  def publish
    @randomization_scheme.update(published: true)
    redirect_to [@project, @randomization_scheme], notice: "Randomization scheme was successfully published."
  end

  # POST /schemes/1/unpublish
  def unpublish
    @randomization_scheme.update(published: false)
    redirect_to [@project, @randomization_scheme], notice: "Randomization scheme was successfully set to draft."
  end

  # DELETE /schemes/1
  def destroy
    @randomization_scheme.destroy
    redirect_to project_randomization_schemes_path(@project), notice: "Randomization scheme was successfully deleted."
  end

  # # GET /schemes/1/randomizations/:randomization_id/edit
  # def edit_randomization
  # end

  # PATCH /schemes/1/randomizations/:randomization_id
  def update_randomization
    if @randomization.update(randomization_params)
      redirect_to [@project, @randomization_scheme], notice: "Randomization was successfully updated."
    else
      render :edit_randomization
    end
  end

  # DELETE /schemes/1/randomizations/:randomization_id
  def destroy_randomization
    @randomization.destroy
    redirect_to [@project, @randomization_scheme], notice: "Randomization was successfully deleted."
  end

  private

  def find_scheme_or_redirect
    @randomization_scheme = @project.randomization_schemes.find_by(id: params[:id])
    redirect_without_scheme
  end

  def find_published_scheme_or_redirect
    @randomization_scheme = @project.randomization_schemes.published.find_by(id: params[:id])
    redirect_without_scheme
  end

  def find_randomization_or_redirect
    @randomization = @randomization_scheme.randomizations.where(subject_id: nil).find_by(id: params[:randomization_id])
    empty_response_or_root_path([@project, @randomization_scheme]) unless @randomization
  end

  def redirect_without_scheme
    empty_response_or_root_path(project_randomization_schemes_path(@project)) unless @randomization_scheme
  end

  def randomization_scheme_params
    params[:randomization_scheme] ||= { blank: "1" }
    check_key_and_set_default_value(:randomization_scheme, :randomization_goal, 0)
    check_key_and_set_default_value(:randomization_scheme, :chance_of_random_treatment_arm_selection, 30)
    if @randomization_scheme && @randomization_scheme.randomized_subjects?
      params.require(:randomization_scheme).permit(
        :name, :description, :randomization_goal,
        { task_hashes: [:description, :offset, :offset_units, :window, :window_units] },
        { expected_randomizations_hashes: [:site_id, :expected] }
      )
    else
      params.require(:randomization_scheme).permit(
        :name, :description, :randomization_goal,
        { task_hashes: [:description, :offset, :offset_units, :window, :window_units] },
        { expected_randomizations_hashes: [:site_id, :expected] },
        :algorithm, :chance_of_random_treatment_arm_selection, :variable_id, :variable_value
      )
    end
  end

  def randomization_params
    params.require(:randomization).permit(:custom_treatment_name)
  end

  def build_criteria_pairs
    criteria_pairs = []
    (params[:stratification_factors] || {}).each do |sf_id, option_id|
      criteria_pairs << [sf_id, option_id]
    end
    criteria_pairs
  end
end
