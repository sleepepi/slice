# Allows project members to launch a tablet handoff that encapsulates a series
# of designs that can be filled out by a subject
class HandoffsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_editable_project_or_editable_site
  before_action :redirect_without_project
  before_action :set_editable_subject
  before_action :redirect_without_subject

  before_action :set_handoff, only: [:show, :edit, :update, :destroy]

  # # GET /handoffs
  # def index
  #   @handoffs = Handoff.all
  # end

  # # GET /handoffs/1
  # def show
  # end

  # GET /handoffs/new
  def new
    @handoff = @project.handoffs.new
  end

  # # GET /handoffs/1/edit
  # def edit
  # end

  # POST /handoffs
  def create
    @handoff = @project.handoffs.where(user_id: current_user.id, subject_event_id: params[:subject_event_id]).first_or_create
    sign_out @user
    redirect_to handoff_start_path(@project.to_param, @handoff.id, @handoff.token)
    #

    # if @handoff.save
    #   redirect_to @handoff, notice: 'Handoff was successfully created.'
    # else
    #   render :new
    # end
  end

  # # PATCH /handoffs/1
  # def update
  #   if @handoff.update(handoff_params)
  #     redirect_to @handoff, notice: 'Handoff was successfully updated.'
  #   else
  #     render :edit
  #   end
  # end

  # # DELETE /handoffs/1
  # def destroy
  #   @handoff.destroy
  #   redirect_to handoffs_path, notice: 'Handoff was successfully destroyed.'
  # end

  private

  def set_editable_subject
    @subject = current_user.all_subjects.find_by_id(params[:id])
  end

  def redirect_without_subject
    empty_response_or_root_path(project_subjects_path(@project)) unless @subject
  end

  def set_handoff
    @handoff = @project.handoffs.find_by_id params[:handoff_id]
  end

  def handoff_params
    params.require(:handoff).permit(:event_id)
  end
end
