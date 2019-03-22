# frozen_string_literal: true

# Displays design images in sections and descriptions.
class DesignImagesController < ApplicationController
  before_action :find_project_or_redirect
  before_action :find_design_or_redirect
  before_action :find_image_or_redirect

  # GET /projects/:project_id/designs/:design_id/images/:id
  def show
    send_file_if_present @image.file
  end

  private

  def find_project_or_redirect
    @project = Project.current.find_by_param(params[:project_id])
    empty_response_or_root_path unless @project
  end

  def find_design_or_redirect
    @design = @project.designs.find_by_param(params[:design_id])
    empty_response_or_root_path unless @design
  end

  def find_image_or_redirect
    @image = @design.design_images.find_by(id: params[:id])
    empty_response_or_root_path unless @image
  end
end
