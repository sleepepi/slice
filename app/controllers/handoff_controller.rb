# Handles tablet handoff after control has been passed to the subject
class HandoffController < ApplicationController
  prepend_before_action { request.env['devise.skip_timeout'] = true }
  skip_before_action :verify_authenticity_token

  before_action :clean_layout
  before_action :set_project, except: [:complete, :completed]
  before_action :set_handoff, except: [:complete, :completed]
  before_action :set_design, only: [:design, :save]

  def start
  end

  def design
  end

  def save
    @sheet = @project.sheets.where(design_id: @design.id).new(subject_id: @handoff.subject_event.subject_id, subject_event_id: @handoff.subject_event_id)
    if SheetTransaction.save_sheet!(@sheet, {}, variables_params, nil, request.remote_ip, 'public_sheet_create')
      design = @handoff.next_design(@design)
      if design
        redirect_to handoff_design_path(@project, @handoff, design)
      else
        @handoff.update token: nil
        redirect_to handoff_complete_path
      end
    else
      render :design
    end
  end

  def complete
    redirect_to handoff_completed_path
  end

  def completed
  end

  private

  def clean_layout
    @no_footer = true
    @no_login = true
  end

  def set_project
    @project = Project.current.find_by_param params[:project]
    redirect_to handoff_complete_path unless @project
  end

  def set_handoff
    @handoff = @project.handoffs.find_by_param params[:handoff]
    redirect_to handoff_complete_path unless @handoff
  end

  def set_design
    @design = @project.designs.find_by_param params[:design]
    redirect_to handoff_complete_path unless @design
    @sheet = @project.sheets.where(design_id: @design.id).new
  end

  def variables_params
    (params[:variables].blank? ? {} : params.require(:variables).permit!)
  end
end
