# frozen_string_literal: true

class RandomizationSchemesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_editable_project_or_editable_site,   only: [:randomize_subject, :subject_search, :randomize_subject_to_list]
  before_action :set_editable_project,                    only: [:add_task, :index, :show, :new, :edit, :create, :update, :destroy]
  before_action :redirect_without_project
  before_action :redirect_blinded_users
  before_action :set_randomization_scheme,                only: [:show, :edit, :update, :destroy]
  before_action :set_published_randomization_scheme,      only: [:randomize_subject, :subject_search, :randomize_subject_to_list]
  before_action :redirect_without_randomization_scheme,   only: [:randomize_subject, :subject_search, :randomize_subject_to_list, :show, :edit, :update, :destroy]

  # POST /template/add_task.js
  def add_task
  end

  def randomize_subject
    @randomization = @project.randomizations.where(randomization_scheme_id: @randomization_scheme).new
  end

  def subject_search
    @subjects = current_user.all_viewable_subjects.where(project_id: @project.id).search(params[:q]).order('subject_code').limit(5)

    result = @subjects.collect do |s|
      status = 'E'
      status_class = 'default'
      randomized = (s.randomizations.where(randomization_scheme_id: @randomization_scheme.id).count == 1)
      if @randomization_scheme.variable
        unless s.has_value?(@randomization_scheme.variable, @randomization_scheme.variable_value)
          # Subject Ineligible for Randomization
          status = 'I'
          status_class = 'danger'
        end
      end
      if randomized
        status = 'R'
        status_class = 'primary'
      end

      stratification_factors = s.stratification_factors(@randomization_scheme)

      { value: s.subject_code, subject_code: s.subject_code, status_class: status_class,
        status: status, site_id: s.site_id, stratification_factors: stratification_factors }
    end

    render json: result
  end

  def randomize_subject_to_list
    @randomization = @project.randomizations.where(randomization_scheme_id: @randomization_scheme).new

    subject = current_user.all_subjects.where(project_id: @project.id).where('LOWER(subjects.subject_code) = ?', params[:subject_code].to_s.downcase).first

    if @randomization_scheme.lists.count == 0
      @randomization.errors.add(:lists, 'need to be generated before a subject can be randomized')
      render 'randomize_subject'
      return
    end

    unless subject
      @randomization.errors.add(:subject_code, 'does not match an existing subject')
      render 'randomize_subject'
      return
    end

    if @randomization_scheme.variable && !subject.has_value?(@randomization_scheme.variable, @randomization_scheme.variable_value)
      variable_message = "#{@randomization_scheme.variable.display_name} is not equal to #{@randomization_scheme.variable_value}"
      @randomization.errors.add(:subject_id, 'is ineligible for randomization due to variable criteria')
      @randomization.errors.add(:subject_id, variable_message)
      render 'randomize_subject'
      return
    end

    criteria_pairs = (params[:stratification_factors] || []).collect { |stratification_factor_id, option_id| [stratification_factor_id, option_id] }
    list = @randomization_scheme.find_list_by_criteria_pairs(criteria_pairs)

    unless list
      @randomization.errors.add(:stratification_factors, "can't be blank")
      render 'randomize_subject'
      return
    end

    invalid_criteria_found = false

    unless @randomization_scheme.all_criteria_selected?(criteria_pairs)
      @randomization.errors.add(:stratification_factors, "can't be blank")
      invalid_criteria_found = true
    end

    expected_stratification_factors = subject.stratification_factors(@randomization_scheme)

    @randomization_scheme.stratification_factors_with_calculation.each do |sf|
      criteria_pair = criteria_pairs.find { |sfid, _oid| sfid == sf.id }
      sfo = sf.stratification_factor_options.find_by_id criteria_pair.last if criteria_pair
      unless sfo && sfo.value.to_s == expected_stratification_factors[sf.id.to_s].to_s
        @randomization.errors.add(sf.name, 'does not match value on specified on subject sheet')
        invalid_criteria_found = true
      end
    end

    if invalid_criteria_found
      render 'randomize_subject'
      return
    end

    stratification_factor = @randomization_scheme.stratification_factors.where(stratifies_by_site: true).first

    if stratification_factor
      if subject.site_id.to_i != (params[:stratification_factors] || {})[stratification_factor.id.to_s.to_sym].to_i
        @randomization.errors.add(:subject_id, 'must be randomized to their site')
        render 'randomize_subject'
        return
      end
    end

    if params[:attested] != '1'
      @randomization.errors.add(:attested, 'must be checked')
      render 'randomize_subject'
      return
    end

    @randomization = @randomization_scheme.randomize_subject_to_list!(subject, list, current_user, criteria_pairs)

    if @randomization && @randomization.errors.full_messages == []
      @randomization.launch_tasks!
      redirect_to [@project, @randomization], notice: "Subject successfully randomized to #{@randomization.treatment_arm.name}."
    elsif @randomization
      @randomization.errors.delete(:subject_id)
      @randomization.errors.add(:subject_id, 'has already been randomized')
      render 'randomize_subject'
    else
      redirect_to choose_scheme_project_randomizations_path(@project), alert: "Subject was NOT successfully randomized. #{@randomization_scheme.randomization_error_message}"
    end
  end

  # GET /randomization_schemes
  # GET /randomization_schemes.json
  def index
    randomization_scheme_scope = @project.randomization_schemes.search(params[:search])
    @order = scrub_order(RandomizationScheme, params[:order], 'randomization_schemes.name')
    randomization_scheme_scope = randomization_scheme_scope.order(@order)
    @randomization_schemes = randomization_scheme_scope.page(params[:page]).per(40)
  end

  # GET /randomization_schemes/1
  # GET /randomization_schemes/1.json
  def show
  end

  # GET /randomization_schemes/new
  def new
    @randomization_scheme = current_user.randomization_schemes.where(project_id: @project.id).new
  end

  # GET /randomization_schemes/1/edit
  def edit
  end

  # POST /randomization_schemes
  # POST /randomization_schemes.json
  def create
    @randomization_scheme = current_user.randomization_schemes.where(project_id: @project.id).new(randomization_scheme_params)

    respond_to do |format|
      if @randomization_scheme.save
        format.html { redirect_to [@project, @randomization_scheme], notice: 'Randomization scheme was successfully created.' }
        format.json { render :show, status: :created, location: @randomization_scheme }
      else
        format.html { render :new }
        format.json { render json: @randomization_scheme.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /randomization_schemes/1
  # PATCH/PUT /randomization_schemes/1.json
  def update
    respond_to do |format|
      if @randomization_scheme.update(randomization_scheme_params)
        format.html { redirect_to [@project, @randomization_scheme], notice: 'Randomization scheme was successfully updated.' }
        format.json { render :show, status: :ok, location: @randomization_scheme }
      else
        format.html { render :edit }
        format.json { render json: @randomization_scheme.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /randomization_schemes/1
  # DELETE /randomization_schemes/1.json
  def destroy
    @randomization_scheme.destroy
    respond_to do |format|
      format.html { redirect_to project_randomization_schemes_path(@project), notice: 'Randomization scheme was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  private

  def set_randomization_scheme
    @randomization_scheme = @project.randomization_schemes.find_by_id(params[:id])
  end

  def set_published_randomization_scheme
    @randomization_scheme = @project.randomization_schemes.published.find_by_id(params[:id])
  end

  def redirect_without_randomization_scheme
    empty_response_or_root_path(project_randomization_schemes_path(@project)) unless @randomization_scheme
  end

  def randomization_scheme_params
    params[:randomization_scheme] ||= { blank: '1' }

    params[:randomization_scheme][:randomization_goal] = 0 if params[:randomization_scheme].key?(:randomization_goal) && params[:randomization_scheme][:randomization_goal].blank?
    params[:randomization_scheme][:chance_of_random_treatment_arm_selection] = 30 if params[:randomization_scheme].key?(:chance_of_random_treatment_arm_selection) && params[:randomization_scheme][:chance_of_random_treatment_arm_selection].blank?

    if @randomization_scheme && @randomization_scheme.randomized_subjects?
      params.require(:randomization_scheme).permit(
        :name, :description, :randomization_goal,
        { task_hashes: [:description, :offset, :offset_units, :window, :window_units] }
      )
    else
      params.require(:randomization_scheme).permit(
        :name, :description, :randomization_goal,
        { task_hashes: [:description, :offset, :offset_units, :window, :window_units] },
        :published, :algorithm, :chance_of_random_treatment_arm_selection, :variable_id, :variable_value)
    end
  end
end
