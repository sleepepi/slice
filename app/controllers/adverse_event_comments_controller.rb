class AdverseEventCommentsController < ApplicationController
  before_action :authenticate_user!

  before_action :set_viewable_project
  before_action :redirect_without_project

  before_action :set_viewable_adverse_event
  before_action :redirect_without_adverse_event

  before_action :set_viewable_adverse_event_comment,     only: [:show]
  before_action :set_editable_adverse_event_comment,     only: [:edit, :update, :destroy]
  before_action :redirect_without_adverse_event_comment, only: [:show, :edit, :update, :destroy]

  # # GET /adverse_event_comments
  # def index
  #   @adverse_event_comments = AdverseEventComment.all
  # end

  # GET /adverse_event_comments/1
  def show
  end

  # # GET /adverse_event_comments/new
  # def new
  #   @adverse_event_comment = current_user.adverse_event_comments.where(project_id: @project.id, adverse_event_id: @adverse_event.id).new
  # end

  # GET /adverse_event_comments/1/edit
  def edit
  end

  # POST /adverse_event_comments.js
  def create
    @adverse_event_comment = current_user.adverse_event_comments.where(project_id: @project.id, adverse_event_id: @adverse_event.id).new(adverse_event_comment_params)
    if @adverse_event_comment.save
      # redirect_to [@project, @adverse_event, @adverse_event_comment], notice: 'Adverse event comment was successfully created.'
      @adverse_event.reload
      render :index
    else
      render :edit
    end
  end

  # PATCH/PUT /adverse_event_comments/1
  def update
    if @adverse_event_comment.update(adverse_event_comment_params)
      # redirect_to [@project, @adverse_event, @adverse_event_comment], notice: 'Adverse event comment was successfully updated.'
      render :show
    else
      render :edit
    end
  end

  # DELETE /adverse_event_comments/1
  def destroy
    @adverse_event_comment.destroy
    # redirect_to [@project, @adverse_event], notice: 'Adverse event comment was successfully destroyed.'
    render :index
  end

  private

  def set_viewable_adverse_event
    @adverse_event = current_user.all_viewable_adverse_events.find_by_id params[:adverse_event_id]
  end

  def set_editable_adverse_event
    @adverse_event = current_user.all_adverse_events.find_by_id params[:adverse_event_id]
  end

  def redirect_without_adverse_event
    empty_response_or_root_path(project_adverse_events_path(@project)) unless @adverse_event
  end

  def set_viewable_adverse_event_comment
    @adverse_event_comment = current_user.all_viewable_adverse_event_comments.find_by_id params[:id]
  end

  def set_editable_adverse_event_comment
    @adverse_event_comment = current_user.all_adverse_event_comments.find_by_id params[:id]
  end

  def redirect_without_adverse_event_comment
    empty_response_or_root_path(project_adverse_event_path(@project, @adverse_event)) unless @adverse_event_comment
  end

  def adverse_event_comment_params
    params.require(:adverse_event_comment).permit(:description, :comment_type)
  end
end
