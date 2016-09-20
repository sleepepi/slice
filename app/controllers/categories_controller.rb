# frozen_string_literal: true

# Categories can only be created and updated by project owners and editors
class CategoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_editable_project
  before_action :redirect_without_project
  before_action :set_category,              only: [:show, :edit, :update, :destroy]
  before_action :redirect_without_category, only: [:show, :edit, :update, :destroy]

  # GET /categories
  def index
    @order = scrub_order(Category, params[:order], 'categories.position')
    @categories = @project.categories
                          .search(params[:search]).reorder(@order)
                          .page(params[:page]).per(40)
  end

  # GET /categories/1
  def show
  end

  # GET /categories/new
  def new
    @category = categories.new(position: @project.categories.count + 1)
  end

  # GET /categories/1/edit
  def edit
  end

  # POST /categories
  def create
    @category = categories.new(category_params)
    if @category.save
      redirect_to [@project, @category], notice: 'Category was successfully created.'
    else
      render :new
    end
  end

  # PATCH /categories/1
  def update
    if @category.update(category_params)
      redirect_to [@project, @category], notice: 'Category was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /categories/1
  def destroy
    @category.destroy
    redirect_to project_categories_path(@project), notice: 'Category was successfully deleted.'
  end

  private

  def categories
    current_user.categories.where(project_id: @project.id)
  end

  def set_category
    @category = @project.categories.find_by_param(params[:id])
  end

  def redirect_without_category
    empty_response_or_root_path(project_categories_path(@project)) unless @category
  end

  def category_params
    params.require(:category).permit(:use_for_adverse_events, :name, :slug, :position, :description)
  end
end
