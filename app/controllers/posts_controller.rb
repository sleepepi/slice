# frozen_string_literal: true

# Allows posts to be made on a project by project editors
class PostsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_editable_project_or_redirect
  before_action :find_editable_post_or_redirect, only: [:show, :edit, :update, :destroy]

  # GET /posts
  def index
    @order = scrub_order(Post, params[:order], 'posts.name')
    @posts = @project.posts.search(params[:search]).order(@order).page(params[:page]).per(20)
  end

  # GET /posts/1
  def show
  end

  # GET /posts/new
  def new
    @post = @project.posts.new
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts
  def create
    @post = current_user.posts.where(project_id: @project.id).new(post_params)
    if @post.save
      redirect_to [@post.project, @post], notice: 'Post was successfully created.'
    else
      render :new
    end
  end

  # PATCH /posts/1
  def update
    if @post.update(post_params)
      redirect_to [@post.project, @post], notice: 'Post was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /posts/1
  def destroy
    @post.destroy
    redirect_to project_posts_path(@project)
  end

  private

  def find_editable_post_or_redirect
    @post = @project.posts.find_by_id(params[:id])
    redirect_without_post
  end

  def redirect_without_post
    empty_response_or_root_path(project_posts_path(@project)) unless @post
  end

  def post_params
    params.require(:post).permit(:name, :description, :archived)
  end
end
