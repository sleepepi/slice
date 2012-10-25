class PostsController < ApplicationController
  before_filter :authenticate_user!
  # GET /posts
  # GET /posts.json
  def index
    @project = current_user.all_projects.find_by_id(params[:project_id])

    if @project
      post_scope = @project.posts.scoped()
      @order = scrub_order(Post, params[:order], "posts.name")
      post_scope = post_scope.order(@order)
      @post_count = post_scope.count
      @posts = post_scope.page(params[:page]).per( 20 )
    end

    respond_to do |format|
      if @project
        format.html # index.html.erb
        format.js
        format.json { render json: @posts }
      else
        format.html { redirect_to root_path }
        format.json { head :no_content }
      end
    end
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
    @project = current_user.all_projects.find_by_id(params[:project_id])
    @post = @project.posts.find_by_id(params[:id]) if @project

    respond_to do |format|
      if @project
        format.html # show.html.erb
        format.json { render json: @post }
      else
        format.html { redirect_to root_path }
        format.json { head :no_content }
      end
    end
  end

  # GET /posts/new
  # GET /posts/new.json
  def new
    @post = Post.new(project_id: params[:project_id])

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @post }
    end
  end

  # GET /posts/1/edit
  def edit
    @project = current_user.all_projects.find_by_id(params[:project_id])
    @post = @project.posts.find_by_id(params[:id]) if @project

    respond_to do |format|
      if @project
        format.html # edit.html.erb
        format.json { render json: @post }
      else
        format.html { redirect_to root_path }
        format.json { head :no_content }
      end
    end
  end

  # POST /posts
  # POST /posts.json
  def create
    @project = current_user.all_projects.find_by_id(params[:project_id])
    @post = @project.posts.new(post_params) if @project

    respond_to do |format|
      if @project
        if @post.save
          format.html { redirect_to [@post.project, @post], notice: 'Post was successfully created.' }
          format.json { render json: @post, status: :created, location: @post }
        else
          format.html { render action: "new" }
          format.json { render json: @post.errors, status: :unprocessable_entity }
        end
      else
        format.html { redirect_to root_path }
        format.json { head :no_content }
      end
    end
  end

  # PUT /posts/1
  # PUT /posts/1.json
  def update
    @project = current_user.all_projects.find_by_id(params[:project_id])
    @post = @project.posts.find_by_id(params[:id]) if @project

    respond_to do |format|
      if @project
        if @post.update_attributes(post_params)
          format.html { redirect_to [@post.project, @post], notice: 'Post was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @post.errors, status: :unprocessable_entity }
        end
      else
        format.html { redirect_to root_path }
        format.json { head :no_content }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @project = current_user.all_projects.find_by_id(params[:project_id])
    @post = @project.posts.find_by_id(params[:id]) if @project

    respond_to do |format|
      if @project
        @post.destroy
        format.html { redirect_to project_posts_path }
        format.json { head :no_content }
      else
        format.html { redirect_to root_path }
        format.json { head :no_content }
      end
    end
  end

  private

  def post_params
    params[:post] ||= {}

    params[:post][:user_id] = current_user.id

    params[:post].slice(
      :name, :description, :archived, :user_id
    )
  end
end
