class PostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_editable_project, only: [ :index, :show, :new, :edit, :create, :update, :destroy ]
  before_action :redirect_without_project, only: [ :index, :show, :new, :edit, :create, :update, :destroy ]
  before_action :set_editable_post, only: [ :show, :edit, :update, :destroy ]
  before_action :redirect_without_post, only: [ :show, :edit, :update, :destroy ]


  # GET /posts
  # GET /posts.json
  def index
    @order = scrub_order(Post, params[:order], "posts.name")
    @posts = @project.posts.search(params[:search]).order(@order).page(params[:page]).per( 20 )
  end

  # GET /posts/1
  # GET /posts/1.json
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
  # POST /posts.json
  def create
    @post = @project.posts.new(post_params)

    respond_to do |format|
      if @post.save
        format.html { redirect_to [@post.project, @post], notice: 'Post was successfully created.' }
        format.json { render action: 'show', status: :created, location: @post }
      else
        format.html { render action: 'new' }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /posts/1
  # PUT /posts/1.json
  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to [@post.project, @post], notice: 'Post was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @post.destroy

    respond_to do |format|
      format.html { redirect_to project_posts_path }
      format.json { head :no_content }
    end
  end

  private

    def set_editable_post
      @post = @project.posts.find_by_id(params[:id])
    end

    def redirect_without_post
      empty_response_or_root_path(project_posts_path) unless @post
    end

    def post_params
      params[:post] ||= {}

      params[:post][:user_id] = current_user.id

      params.require(:post).permit(
        :name, :description, :archived, :user_id
      )
    end

end
