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
    current_user.all_viewable_subjects
                .search(params[:search]).order(:subject_code).limit(10)
  end

  def projects
    current_user.all_viewable_and_site_projects
                .search(params[:search], match_start: false).order(:name).limit(10)
  end

  def designs
    current_user.all_viewable_designs
                .search(params[:search], match_start: false).order(:name).limit(10)
  end

  def variables
    current_user.all_viewable_variables
                .search(params[:search], match_start: false).order(:name).limit(10)
  end
end
