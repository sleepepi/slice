# frozen_string_literal: true

# Provides back search results from across projects.
class SearchController < ApplicationController
  before_action :authenticate_user!
  before_action :filter_objects, only: :index

  # GET /search
  def index
    return unless @objects.size == 1
    if @objects.first.respond_to?(:project)
      redirect_to [@objects.first.project, @objects.first]
    else
      redirect_to @objects.first
    end
  end

  private

  def filter_objects
    @subjects = subjects
    @projects = projects
    @designs = designs
    @variables = variables
    @objects = @subjects + @projects + @designs + @variables
  end

  def subjects
    return Subject.none if params[:search].blank?
    current_user.all_viewable_subjects
                .search_any_order(params[:search]).order(:subject_code).limit(10)
  end

  def projects
    return Project.none if params[:search].blank?
    current_user.all_viewable_and_site_projects
                .search_any_order(params[:search]).order(:name).limit(10)
  end

  def designs
    return Design.none if params[:search].blank?
    current_user.all_viewable_designs
                .search_any_order(params[:search]).order(:name).limit(10)
  end

  def variables
    return Variable.none if params[:search].blank?
    current_user.all_viewable_variables
                .search_any_order(params[:search]).order(:name).limit(10)
  end
end
