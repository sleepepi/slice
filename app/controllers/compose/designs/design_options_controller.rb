# frozen_string_literal: true

# Allows project editors to edit and update design options.
class Compose::Designs::DesignOptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_editable_project_or_redirect
  before_action :find_editable_design_or_redirect
  before_action :find_design_option_or_redirect, only: [:show, :edit, :update]

  # # GET /compose/projects/:project_id/designs/:design_id/options/:id
  # def show
  # end

  # # GET /compose/projects/:project_id/designs/:design_id/options/:id/edit
  # def edit
  # end

  # PATCH /compose/projects/:project_id/designs/:design_id/options/:id
  def update
    if @design_option.update(design_option_params)
      render :show
    else
      render :edit
    end
  end

  private

  def design_option_params
    params.require(:design_option).permit(
      :branching_logic, :position, :requirement
    )
  end

  def find_editable_design_or_redirect
    @design = current_user.all_designs.where(project: @project).find_by_param(params[:design_id])
    empty_response_or_root_path(project_designs_path(@project)) unless @design
  end

  def find_design_option_or_redirect
    @design_option = @design.design_options.find_by(id: params[:id])
    empty_response_or_root_path(project_design_path(@project, @design)) unless @design_option
  end
end
