# frozen_string_literal: true

# Allows project editors to edit and update design sections.
class Compose::Designs::DesignOptions::SectionsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_editable_project_or_redirect
  before_action :find_editable_design_or_redirect
  before_action :find_design_option_or_redirect
  before_action :find_section_or_redirect, only: [:show, :edit, :update]

  # # GET /compose/projects/:project_id/designs/:design_id/options/:design_option_id/sections/:id
  # def show
  # end

  # # GET /compose/projects/:project_id/designs/:design_id/options/:design_option_id/sections/:id/edit
  # def edit
  # end

  # PATCH /compose/projects/:project_id/designs/:design_id/options/:design_option_id/sections/:id
  def update
    if @section.update_or_translate(section_params)
      render :show
    else
      render :edit
    end
  end

  private

  def section_params
    params.require(:section).permit(
      :name, :description, :level
    )
  end

  def find_editable_design_or_redirect
    @design = current_user.all_designs.where(project: @project).find_by_param(params[:design_id])
    empty_response_or_root_path(project_designs_path(@project)) unless @design
  end

  def find_design_option_or_redirect
    @design_option = @design.design_options.find_by(id: params[:design_option_id])
    empty_response_or_root_path(project_design_path(@project, @design)) unless @design_option
  end

  def find_section_or_redirect
    @section = @design.sections.find_by(id: params[:id])
    empty_response_or_root_path(project_design_path(@project, @design)) unless @section
  end
end
