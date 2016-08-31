# frozen_string_literal: true

# Handles tablet handoff after control has been passed to the subject
class HandoffController < ApplicationController
  prepend_before_action { request.env['devise.skip_timeout'] = true }
  skip_before_action :verify_authenticity_token

  before_action :clean_layout
  before_action :set_project, except: [:completed]
  before_action :set_handoff, except: [:completed]
  before_action :set_design, only: [:design, :save]
  before_action :set_sheet, only: [:design, :save]

  def start
  end

  def design
  end

  def save
    update_type = (@sheet.new_record? ? 'public_sheet_create' : 'public_sheet_update')
    if SheetTransaction.save_sheet!(@sheet, {}, variables_params, nil, request.remote_ip, update_type)
      progress_to_next_design
    else
      render :design
    end
  end

  def completed
  end

  private

  def clean_layout
    @no_footer = true
  end

  def set_project
    @project = Project.current.find_by_param params[:project]
    redirect_to handoff_completed_path unless @project
  end

  def set_handoff
    @handoff = @project.handoffs.find_by_param params[:handoff]
    redirect_to handoff_completed_path unless @handoff
  end

  def set_design
    @design = @project.designs.find_by_param params[:design]
    redirect_to handoff_completed_path unless @design
  end

  def set_sheet
    @sheet = @project.sheets.find_by(design_id: @design.id, subject_event_id: @handoff.subject_event_id)
    @sheet = @project.sheets.where(design_id: @design.id).new(sheet_params) unless @sheet
  end

  def sheet_params
    { subject_id: @handoff.subject_event.subject_id, subject_event_id: @handoff.subject_event_id }
  end

  def variables_params
    (params[:variables].blank? ? {} : params.require(:variables).permit!)
  end

  def progress_to_next_design
    design = @handoff.next_design(@design)
    if design
      redirect_to handoff_design_path(@project, @handoff, design)
    else
      @handoff.completed!
      redirect_to handoff_completed_path
    end
  end
end
