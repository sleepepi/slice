# frozen_string_literal: true

# Allows project owners, editors, and viewers to leave comments on a sheet
class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_viewable_sheet, only: [:new, :create]
  before_action :set_viewable_comment, only: [:show]
  before_action :set_editable_comment, only: [:edit, :update]
  before_action :set_deletable_comment, only: [:destroy]

  # GET /comments/1
  # GET /comments/1.js
  def show
    respond_to do |format|
      format.html { redirect_to project_sheet_path(@comment.project, @comment.sheet, anchor: @comment.anchor) }
      format.js
    end
  end

  # GET /comments/1/edit
  def edit
  end

  # POST /comments
  def create
    @comment = current_user.comments.where(sheet_id: @sheet.id).new(comment_params)
    if @comment.save
      render :index
    else
      render :edit
    end
  end

  # PATCH /comments/1
  def update
    if @comment.update(comment_params)
      render :show
    else
      render :edit
    end
  end

  # DELETE /comments/1
  def destroy
    @comment.destroy
  end

  private

  def set_viewable_sheet
    @sheet = current_user.all_viewable_sheets.find_by_id params[:sheet_id]
    redirect_without_sheet
  end

  def redirect_without_sheet
    empty_response_or_root_path unless @sheet
  end

  def set_viewable_comment
    @comment = current_user.all_viewable_comments.find_by_id params[:id]
    redirect_without_comment
  end

  def set_editable_comment
    @comment = current_user.all_editable_comments.find_by_id params[:id]
    redirect_without_comment
  end

  def set_deletable_comment
    @comment = current_user.all_deletable_comments.find_by_id params[:id]
    redirect_without_comment
  end

  def redirect_without_comment
    empty_response_or_root_path unless @comment
  end

  def comment_params
    params.require(:comment).permit(:description)
  end
end
