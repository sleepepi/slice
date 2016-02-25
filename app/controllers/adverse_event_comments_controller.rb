# frozen_string_literal: true

# Allows project editors and owners to discuss adverse events. Comments are
# disabled for sheets associated with an adverse event to centralize discussion.
# Comments can be made by unblinded project and site members.
class AdverseEventCommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_editable_project_or_editable_site
  before_action :redirect_without_project
  before_action :set_adverse_event
  before_action :set_viewable_adverse_event_comment,     only: [:show]
  before_action :set_editable_adverse_event_comment,     only: [:edit, :update, :destroy]

  # GET /adverse-events/:adverse_event_id/comments/1.js
  def show
  end

  # GET /adverse-events/:adverse_event_id/comments/1/edit.js
  def edit
  end

  # POST /adverse-events/:adverse_event_id/comments.js
  def create
    @adverse_event_comment = current_user.adverse_event_comments
                                         .where(project_id: @project.id, adverse_event_id: @adverse_event.id)
                                         .new(adverse_event_comment_params)
    if @adverse_event_comment.save
      @adverse_event.reload
      @last_seen_at = @adverse_event.last_seen_at current_user
      render :index
    else
      render :edit
    end
  end

  # PATCH /adverse-events/:adverse_event_id/comments/1.js
  def update
    if @adverse_event_comment.update(adverse_event_comment_params)
      render :show
    else
      render :edit
    end
  end

  # DELETE /adverse-events/:adverse_event_id/comments/1.js
  def destroy
    @adverse_event_comment.destroy
    render :index
  end

  private

  def set_adverse_event
    @adverse_event = current_user.all_viewable_adverse_events.find_by_id params[:adverse_event_id]
    redirect_without_adverse_event
  end

  def redirect_without_adverse_event
    empty_response_or_root_path(project_adverse_events_path(@project)) unless @adverse_event
  end

  def set_viewable_adverse_event_comment
    @adverse_event_comment = current_user.all_viewable_adverse_event_comments.find_by_id params[:id]
    redirect_without_adverse_event_comment
  end

  def set_editable_adverse_event_comment
    @adverse_event_comment = current_user.all_adverse_event_comments.find_by_id params[:id]
    redirect_without_adverse_event_comment
  end

  def redirect_without_adverse_event_comment
    empty_response_or_root_path(project_adverse_event_path(@project, @adverse_event)) unless @adverse_event_comment
  end

  def adverse_event_comment_params
    params.require(:adverse_event_comment).permit(:description, :comment_type)
  end
end
