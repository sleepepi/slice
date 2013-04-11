class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_viewable_sheet, only: [ :new, :create ]
  before_action :redirect_without_sheet, only: [ :new, :create ]
  before_action :set_viewable_comment, only: [ :show ]
  before_action :set_editable_comment, only: [ :edit, :update ]
  before_action :set_deletable_comment, only: [ :destroy ]
  before_action :redirect_without_comment, only: [ :show, :edit, :update, :destroy ]

  # GET /comments
  # GET /comments.json
  def index
    @order = scrub_order(Comment, params[:order], 'created_at DESC')
    @comments = current_user.all_viewable_comments.order(@order).page(params[:page]).per(50)
  end

  # GET /comments/1
  # GET /comments/1.json
  def show
  end

  # GET /comments/new
  def new
    @comment = @sheet.comments.new(comment_params)
  end

  # GET /comments/1/edit
  def edit
  end

  # POST /comments
  # POST /comments.json
  def create
    @comment = @sheet.comments.new(comment_params)

    respond_to do |format|
      if @comment.save
        format.html { redirect_to @comment, notice: 'Comment was successfully created.' }
        format.js
        format.json { render action: 'show', status: :created, location: @comment }
      else
        format.html { render action: 'new' }
        format.js
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /comments/1
  # PATCH/PUT /comments/1.json
  def update
    respond_to do |format|
      if @comment.update(comment_params)
        format.html { redirect_to @comment, notice: 'Comment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.json
  def destroy
    @comment.destroy

    respond_to do |format|
      format.html { redirect_to comments_path }
      format.js
      format.json { head :no_content }
    end
  end

  private

    def set_viewable_sheet
      @sheet = current_user.all_viewable_sheets.find_by_id(params[:sheet_id])
    end

    def redirect_without_sheet
      empty_response_or_root_path unless @sheet
    end

    def set_viewable_comment
      @comment = current_user.all_viewable_comments.find_by_id(params[:id])
    end

    def set_editable_comment
      @comment = current_user.all_comments.find_by_id(params[:id])
    end

    def set_deletable_comment
      @comment = current_user.all_deletable_comments.find_by_id(params[:id])
    end

    def redirect_without_comment
      empty_response_or_root_path(comments_path) unless @comment
    end

    def comment_params
      params[:comment] ||= {}

      params[:comment][:user_id] = current_user.id unless @comment

      params.require(:comment).permit(
        :description, :user_id
      )
    end

end
