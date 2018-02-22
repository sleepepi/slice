# frozen_string_literal: true

# Allows project members to launch a tablet handoff that encapsulates a series
# of designs that can be filled out by a subject.
class HandoffsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_editable_project_or_editable_site_or_redirect
  before_action :find_editable_subject_or_redirect
  before_action :find_handoff

  # # GET /handoffs/new
  # def new
  # end

  # POST /handoffs
  def create
    sign_out current_user
    redirect_to handoff_start_path(@project, @handoff)
  end

  private

  def find_editable_subject_or_redirect
    @subject = current_user.all_subjects.where(project: @project).find_by(id: params[:id])
    redirect_without_subject
  end

  def redirect_without_subject
    empty_response_or_root_path(project_subjects_path(@project)) unless @subject
  end

  def find_handoff
    @handoff = @project.handoffs.where(handoff_params).first_or_create(user_id: current_user.id)
    @handoff.set_token
  end

  def handoff_params
    { subject_event_id: params[:subject_event_id] }
  end
end
