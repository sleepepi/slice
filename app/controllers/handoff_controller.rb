# Handles tablet handoff after control has been passed to the subject
class HandoffController < ApplicationController
  before_action :set_project, except: [:complete, :completed]
  before_action :set_handoff, except: [:complete, :completed]
  before_action :set_design, only: [:design]
  # before_action :set_cache_buster

  def start
  end

  def design

  end

  def complete
    redirect_to handoff_completed_path
  end

  def completed
  end

  private

  def set_project
    @project = Project.current.find_by_param params[:project]
    redirect_to root_path unless @project
  end

  def set_handoff
    @handoff = @project.handoffs.find_by_id params[:handoff_id]
    # Use Devise.secure_compare to mitigate timing attacks
    return if @handoff && Devise.secure_compare(@handoff.token, params[:handoff_token])
    redirect_to root_path
  end

  def set_design
    @design = @project.designs.find_by_id params[:design_id]
    redirect_to root_path unless @design
    @sheet = @project.sheets.where(design_id: @design.id).new
  end

  # def set_cache_buster
  #   response.headers['Cache-Control'] = 'no-cache, no-store, max-age=0, must-revalidate'
  #   response.headers['Pragma'] = 'no-cache'
  #   response.headers['Expires'] = 'Fri, 01 Jan 1990 00:00:00 GMT'
  # end
end
