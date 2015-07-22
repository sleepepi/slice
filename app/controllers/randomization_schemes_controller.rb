class RandomizationSchemesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_editable_project
  before_action :redirect_without_project
  before_action :set_randomization_scheme,                only: [:show, :edit, :update, :destroy]
  before_action :set_published_randomization_scheme,      only: [:randomize_subject, :randomize_subject_to_list]
  before_action :redirect_without_randomization_scheme,   only: [:randomize_subject, :randomize_subject_to_list, :show, :edit, :update, :destroy]

  def randomize_subject
    @randomization = @project.randomizations.where(randomization_scheme_id: @randomization_scheme).new
  end

  def randomize_subject_to_list
    @randomization = @project.randomizations.where(randomization_scheme_id: @randomization_scheme).new

    subject = current_user.all_subjects.where(project_id: @project.id).where("LOWER(subjects.subject_code) = ?", params[:subject_code].to_s.downcase).first

    if @randomization_scheme.lists.count == 0
      @randomization.errors.add(:lists, "need to be generated before a subject can be randomized")
      render 'randomize_subject'
      return
    end

    unless subject
      @randomization.errors.add(:subject_code, "can't be blank")
      render 'randomize_subject'
      return
    end

    criteria_pairs = (params[:stratification_factors] || []).collect{ |stratification_factor_id, option_id| [stratification_factor_id, option_id] }
    list = @randomization_scheme.find_list_by_criteria_pairs(criteria_pairs)

    unless list
      @randomization.errors.add(:stratification_factors, "can't be blank")
      render 'randomize_subject'
      return
    end

    if params[:attested] != '1'
      @randomization.errors.add(:attested, "must be checked")
      render 'randomize_subject'
      return
    end

    @randomization = @randomization_scheme.randomize_subject_to_list!(subject, list, current_user, criteria_pairs)

    if @randomization and @randomization.errors.full_messages == []
      redirect_to [@project, @randomization], notice: "Subject successfully randomized to #{@randomization.treatment_arm.name}."
    elsif @randomization
      @randomization.errors.delete(:subject_id)
      @randomization.errors.add(:subject_id, "has already been randomized")
      render 'randomize_subject'
    else
      redirect_to choose_randomization_scheme_project_path(@project), alert: "Subject was NOT successfully randomized. #{@randomization_scheme.randomization_error_message}"
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
      format.html { redirect_to project_randomization_schemes_path(@project), notice: 'Randomization scheme was successfully destroyed.' }
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

      params[:randomization_scheme][:randomization_goal] = 0 if params[:randomization_scheme].has_key?(:randomization_goal) and params[:randomization_scheme][:randomization_goal].blank?
      params[:randomization_scheme][:chance_of_random_treatment_arm_selection] = 30 if params[:randomization_scheme].has_key?(:chance_of_random_treatment_arm_selection) and params[:randomization_scheme][:chance_of_random_treatment_arm_selection].blank?

      if @randomization_scheme and @randomization_scheme.has_randomized_subjects?
        params.require(:randomization_scheme).permit(:name, :description, :randomization_goal)
      else
        params.require(:randomization_scheme).permit(:name, :description, :randomization_goal, :published, :algorithm, :chance_of_random_treatment_arm_selection)
      end
    end
end
