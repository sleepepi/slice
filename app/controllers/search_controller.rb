# frozen_string_literal: true

# Provides back search results from across projects.
class SearchController < ApplicationController
  before_action :authenticate_user!

  # GET /search
  # GET /search.json
  def index
    @subjects = current_user.all_viewable_subjects.search(params[:q]).order('subject_code').limit(10)
    @projects = current_user.all_viewable_projects.search(params[:q]).order('name').limit(10)
    @designs = current_user.all_viewable_designs.search(params[:q]).order('name').limit(10)
    @variables = current_user.all_viewable_variables.search(params[:q]).order('name').limit(10)

    @objects = @subjects + @projects + @designs + @variables

    respond_to do |format|
      format.json { render json: ([params[:q]] + @objects.collect(&:name)).uniq }
      format.html do
        redirect_to [@objects.first.project, @objects.first] if @objects.size == 1 && @objects.first.respond_to?('project')
        redirect_to @objects.first if @objects.size == 1 && !@objects.first.respond_to?('project')
      end
    end
  end
end
