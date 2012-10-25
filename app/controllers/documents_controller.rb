class DocumentsController < ApplicationController
  before_filter :authenticate_user!

  # GET /documents
  # GET /documents.json
  def index
    @project = current_user.all_projects.find_by_id(params[:project_id])

    if @project
      document_scope = @project.documents.scoped()
      @order = scrub_order(Document, params[:order], "documents.name")
      document_scope = document_scope.order(@order)
      @document_count = document_scope.count
      @documents = document_scope.page(params[:page]).per( 20 )
    end

    respond_to do |format|
      if @project
        format.html # index.html.erb
        format.js
        format.json { render json: @documents }
      else
        format.html { redirect_to root_path }
        format.json { head :no_content }
      end
    end
  end

  # GET /documents/1
  # GET /documents/1.json
  def show
    @project = current_user.all_projects.find_by_id(params[:project_id])
    @document = @project.documents.find_by_id(params[:id]) if @project

    respond_to do |format|
      if @project
        format.html # show.html.erb
        format.json { render json: @document }
      else
        format.html { redirect_to root_path }
        format.json { head :no_content }
      end
    end
  end

  # GET /documents/new
  # GET /documents/new.json
  def new
    @document = Document.new(project_id: params[:project_id])

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @document }
    end
  end

  # GET /documents/1/edit
  def edit
    @project = current_user.all_projects.find_by_id(params[:project_id])
    @document = @project.documents.find_by_id(params[:id]) if @project

    respond_to do |format|
      if @project
        format.html # edit.html.erb
        format.json { render json: @document }
      else
        format.html { redirect_to root_path }
        format.json { head :no_content }
      end
    end
  end

  # POST /documents
  # POST /documents.json
  def create
    @project = current_user.all_projects.find_by_id(params[:project_id])
    @document = @project.documents.new(post_params) if @project

    respond_to do |format|
      if @project
        if @document.save
          format.html { redirect_to [@document.project, @document], notice: 'Document was successfully created.' }
          format.json { render json: @document, status: :created, location: @document }
        else
          format.html { render action: "new" }
          format.json { render json: @document.errors, status: :unprocessable_entity }
        end
      else
        format.html { redirect_to root_path }
        format.json { head :no_content }
      end
    end
  end

  # PUT /documents/1
  # PUT /documents/1.json
  def update
    @project = current_user.all_projects.find_by_id(params[:project_id])
    @document = @project.documents.find_by_id(params[:id]) if @project

    respond_to do |format|
      if @project
        if @document.update_attributes(post_params)
          format.html { redirect_to [@document.project, @document], notice: 'Document was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @document.errors, status: :unprocessable_entity }
        end
      else
        format.html { redirect_to root_path }
        format.json { head :no_content }
      end
    end
  end

  # DELETE /documents/1
  # DELETE /documents/1.json
  def destroy
    @project = current_user.all_projects.find_by_id(params[:project_id])
    @document = @project.documents.find_by_id(params[:id]) if @project

    respond_to do |format|
      if @project
        @document.destroy
        format.html { redirect_to project_documents_path }
        format.json { head :no_content }
      else
        format.html { redirect_to root_path }
        format.json { head :no_content }
      end
    end
  end

  private

  def post_params
    params[:document] ||= {}

    params[:document][:user_id] = current_user.id

    params[:document].slice(
      :name, :category, :file, :file_cache, :archived, :user_id
    )
  end
end
