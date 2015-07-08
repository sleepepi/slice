class RandomizationSchemesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_editable_project
  before_action :redirect_without_project
  before_action :set_randomization_scheme,                only: [:randomize_subject, :randomize_subject_to_list, :show, :edit, :update, :destroy]
  before_action :redirect_without_randomization_scheme,   only: [:randomize_subject, :randomize_subject_to_list, :show, :edit, :update, :destroy]

  def randomize_subject
    @randomization = @project.randomizations.where(randomization_scheme_id: @randomization_scheme).new
  end

  def randomize_subject_to_list

    render text: params.inspect



    # subject = @project.subjects...
    # list = @randomization_scheme.lists...
    # @randomization_scheme.randomize_subject_to_list!(subject, list, current_user)




    # From Randomization Web Application
    # stratum_keys = params.keys.select{|key| key =~ /^stratum_[\d]*$/}
    # values = params.each.select{|key, value| stratum_keys.include?(key)}.collect{|k,v| v}.compact

    # if @assignment = @project.create_randomization!(params[:subject_code], values, current_user, params[:attested].to_i == 1)
    #   redirect_to [@project, @assignment], notice: "Subject successfully randomized to #{@assignment.treatment_arm}.".html_safe
    # else
    #   render action: 'randomize_subject'
    # end
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

    def redirect_without_randomization_scheme
      empty_response_or_root_path(project_randomization_schemes_path(@project)) unless @randomization_scheme
    end

    def randomization_scheme_params
      params[:randomization_scheme] ||= { blank: '1' }

      params[:randomization_scheme][:randomization_goal] = 0 if params[:randomization_scheme].has_key?(:randomization_goal) and params[:randomization_scheme][:randomization_goal].blank?

      params.require(:randomization_scheme).permit(:name, :description, :published, :randomization_goal)
    end
end
