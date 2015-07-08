class ListsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_editable_project
  before_action :redirect_without_project
  before_action :set_randomization_scheme
  before_action :redirect_without_randomization_scheme

  before_action :set_list,                only: [:show, :edit, :update, :destroy]
  before_action :redirect_without_list,   only: [:show, :edit, :update, :destroy]


  # GET /lists
  # GET /lists.json
  def index
    @lists = @randomization_scheme.lists.order(:name).page(params[:page]).per(40)
  end

  # GET /lists/1
  # GET /lists/1.json
  def show
  end

  # GET /lists/new
  def new
    @list = @randomization_scheme.lists.where(project_id: @project.id, user_id: current_user.id).new
  end

  # GET /lists/1/edit
  def edit
  end

  # POST /lists
  # POST /lists.json
  def create
    @list = @randomization_scheme.lists.where(project_id: @project.id, user_id: current_user.id).new(list_params)

    respond_to do |format|
      if @list.save
        format.html { redirect_to [@project, @randomization_scheme, @list], notice: 'List was successfully created.' }
        format.json { render :show, status: :created, location: @list }
      else
        format.html { render :new }
        format.json { render json: @list.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /lists/1
  # PATCH/PUT /lists/1.json
  def update
    respond_to do |format|
      if @list.update(list_params)
        format.html { redirect_to [@project, @randomization_scheme, @list], notice: 'List was successfully updated.' }
        format.json { render :show, status: :ok, location: @list }
      else
        format.html { render :edit }
        format.json { render json: @list.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /lists/1
  # DELETE /lists/1.json
  def destroy
    @list.destroy
    respond_to do |format|
      format.html { redirect_to project_randomization_scheme_lists_path(@project, @randomization_scheme), notice: 'List was successfully destroyed.' }
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

    def set_list
      @list = @randomization_scheme.lists.find_by_id(params[:id])
    end

    def redirect_without_list
      empty_response_or_root_path(project_randomization_scheme_lists_path(@project, @randomization_scheme)) unless @list
    end

    def list_params
      params.require(:list).permit(:name)
    end
end
