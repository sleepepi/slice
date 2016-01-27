# frozen_string_literal: true

class ListsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_editable_project
  before_action :redirect_without_project
  before_action :redirect_blinded_users
  before_action :set_randomization_scheme
  before_action :redirect_without_randomization_scheme

  before_action :set_list,                only: [:show]
  before_action :redirect_without_list,   only: [:show]

  def generate
    if @randomization_scheme.generate_lists!(current_user)
      flash[:notice] = 'Lists were successfully created.'
    else
      flash[:alert] = 'Lists were NOT successfully created. Please be sure to UNDO any existing randomizations.'
    end
    redirect_to [@project, @randomization_scheme]
  end

  def expand
    @randomization_scheme.add_missing_lists!(current_user)
    flash[:notice] = 'Additional lists were successfully created.'
    redirect_to [@project, @randomization_scheme]
  end

  # GET /lists
  # GET /lists.json
  def index
    @lists = @randomization_scheme.lists.order(:id).page(params[:page]).per(40)
  end

  # GET /lists/1
  # GET /lists/1.json
  def show
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

end
