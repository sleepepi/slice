# frozen_string_literal: true

# Allows project editors to add links to projects.
class LinksController < ApplicationController
  before_action :authenticate_user!
  before_action :find_editable_project_or_redirect
  before_action :find_link_or_redirect, only: [:show, :edit, :update, :destroy]

  # GET /links
  def index
    @order = scrub_order(Link, params[:order], 'links.name')
    @links = @project.links.search(params[:search]).order(@order).page(params[:page]).per(20)
  end

  # GET /links/1
  def show
  end

  # GET /links/new
  def new
    @link = @project.links.new
  end

  # GET /links/1/edit
  def edit
  end

  # POST /links
  def create
    @link = current_user.links.where(project_id: @project.id).new(link_params)
    if @link.save
      redirect_to [@link.project, @link], notice: 'Link was successfully created.'
    else
      render :new
    end
  end

  # PATCH /links/1
  def update
    original_category = @link.category
    if @link.update(link_params)
      @project.links.where(category: original_category)
              .update_all(category: @link.category) if params[:rename_category] == '1'
      redirect_to [@link.project, @link], notice: 'Link was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /links/1
  def destroy
    @link.destroy
    redirect_to project_links_path(@project)
  end

  private

  def find_link_or_redirect
    @link = @project.links.find_by_id params[:id]
    redirect_without_link
  end

  def redirect_without_link
    empty_response_or_root_path(project_links_path(@project)) unless @link
  end

  def link_params
    params.require(:link).permit(:name, :category, :url, :archived)
  end
end
