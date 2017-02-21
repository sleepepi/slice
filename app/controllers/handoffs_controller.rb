# frozen_string_literal: true

# Allows project members to launch a tablet handoff that encapsulates a series
# of designs that can be filled out by a subject
class HandoffsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_editable_project_or_editable_site
  before_action :redirect_without_project
  before_action :set_editable_subject
  before_action :redirect_without_subject
  before_action :set_handoff

  # GET /handoffs/new
  def new
  end

  # POST /handoffs
  def create
    sign_out @user
    redirect_to handoff_start_path(@project, @handoff)
  end

  private

  def set_editable_subject
    @subject = current_user.all_subjects.find_by(id: params[:id])
  end

  def redirect_without_subject
    empty_response_or_root_path(project_subjects_path(@project)) unless @subject
  end

  def set_handoff
    @handoff = @project.handoffs.where(handoff_params).first_or_create(user_id: current_user.id)
    @handoff.set_token
  end

  def handoff_params
    { subject_event_id: params[:subject_event_id] }
  end
end
