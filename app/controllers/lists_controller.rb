# frozen_string_literal: true

# Allows randomization scheme lists to be displayed.
class ListsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_editable_project_or_redirect
  before_action :redirect_blinded_users
  before_action :find_randomization_scheme_or_redirect
  before_action :check_custom_list_or_redirect, only: [:edit, :update]
  before_action :find_list_or_redirect, only: [:show, :edit, :update]


  layout "layouts/full_page_sidebar_dark"

  def generate
    if @randomization_scheme.generate_lists!(current_user)
      flash[:notice] = "Lists were successfully created."
    elsif @randomization_scheme.randomized_subjects?
      flash[:alert] = "Lists were NOT successfully created. Please be sure to UNDO any existing randomizations."
    else
      flash[:alert] = "Lists were NOT successfully created. Too many permutations for stratification factors."
    end
    redirect_to [@project, @randomization_scheme]
  end

  def expand
    if @randomization_scheme.add_missing_lists!(current_user)
      flash[:notice] = "Additional lists were successfully created."
    else
      flash[:alert] = "Additional lists were NOT successfully created. Too many permutations for stratification factors."
    end
    redirect_to [@project, @randomization_scheme]
  end

  # GET /lists/1/edit
  # def edit
  # end

  def update
    @list.append_items!(params.dig(:list, :items), current_user)
    redirect_to [@project, @randomization_scheme], notice: "Items successfully added."
  end

  # GET /lists
  def index
    @lists = @randomization_scheme.lists.order(:id).page(params[:page]).per(40)
  end

  # # GET /lists/1
  # def show
  # end

  private

  def find_randomization_scheme_or_redirect
    @randomization_scheme = @project.randomization_schemes.find_by(id: params[:randomization_scheme_id])
    redirect_without_randomization_scheme
  end

  def redirect_without_randomization_scheme
    empty_response_or_root_path(project_randomization_schemes_path(@project)) unless @randomization_scheme
  end

  def check_custom_list_or_redirect
    redirect_to [@project, @randomization_scheme] unless @randomization_scheme.custom_list?
  end

  def find_list_or_redirect
    @list = @randomization_scheme.lists.find_by(id: params[:id])
    redirect_without_list
  end

  def redirect_without_list
    empty_response_or_root_path(project_randomization_scheme_lists_path(@project, @randomization_scheme)) unless @list
  end
end
