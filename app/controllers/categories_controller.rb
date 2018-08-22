# frozen_string_literal: true

# Categories can only be created and updated by project owners and editors.
class CategoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :find_editable_project_or_redirect
  before_action :find_category_or_redirect, only: [:show, :edit, :update, :destroy]

  layout "layouts/full_page_sidebar"

  # GET /categories
  def index
    scope = @project.categories.search_any_order(params[:search])
    @categories = scope_order(scope).page(params[:page]).per(40)
  end

  # # GET /categories/1
  # def show
  # end

  # GET /categories/new
  def new
    @category = categories.new(position: @project.categories.count + 1)
  end

  # # GET /categories/1/edit
  # def edit
  # end

  # POST /categories
  def create
    @category = categories.new(category_params)
    if @category.save
      redirect_to [@project, @category], notice: "Category was successfully created."
    else
      render :new
    end
  end

  # PATCH /categories/1
  def update
    if @category.update(category_params)
      redirect_to [@project, @category], notice: "Category was successfully updated."
    else
      render :edit
    end
  end

  # DELETE /categories/1
  def destroy
    @category.destroy
    redirect_to project_categories_path(@project), notice: "Category was successfully deleted."
  end

  private

  def categories
    current_user.categories.where(project_id: @project.id)
  end

  def find_category_or_redirect
    @category = @project.categories.find_by_param(params[:id])
    redirect_without_category
  end

  def redirect_without_category
    empty_response_or_root_path(project_categories_path(@project)) unless @category
  end

  def category_params
    params.require(:category).permit(
      :use_for_adverse_events, :name, :slug, :position, :description
    )
  end

  def scope_order(scope)
    @order = scrub_order(Category, params[:order], "categories.position")
    scope.reorder(@order)
  end
end
