class DocumentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :set_editable_project, only: [ :index, :show, :new, :edit, :create, :update, :destroy ]
  before_filter :redirect_without_project, only: [ :index, :show, :new, :edit, :create, :update, :destroy ]
  before_filter :set_editable_document, only: [ :show, :edit, :update, :destroy ]
  before_filter :redirect_without_document, only: [ :show, :edit, :update, :destroy ]


  # GET /documents
  # GET /documents.json
  def index
    @order = scrub_order(Document, params[:order], "documents.name")
    @documents = @project.documents.search(params[:search]).order(@order).page(params[:page]).per( 20 )

    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.json { render json: @documents }
    end
  end

  # GET /documents/1
  # GET /documents/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @document }
    end
  end

  # GET /documents/new
  # GET /documents/new.json
  def new
    @document = @project.documents.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @document }
    end
  end

  # GET /documents/1/edit
  def edit
    respond_to do |format|
      format.html # edit.html.erb
      format.json { render json: @document }
    end
  end

  # POST /documents
  # POST /documents.json
  def create
    @document = @project.documents.new(post_params)

    respond_to do |format|
      if @document.save
        format.html { redirect_to [@document.project, @document], notice: 'Document was successfully created.' }
        format.json { render json: @document, status: :created, location: @document }
      else
        format.html { render action: "new" }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /documents/1
  # PUT /documents/1.json
  def update
    respond_to do |format|
      if @document.update_attributes(post_params)
        format.html { redirect_to [@document.project, @document], notice: 'Document was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /documents/1
  # DELETE /documents/1.json
  def destroy
    @document.destroy

    respond_to do |format|
      format.html { redirect_to project_documents_path }
      format.json { head :no_content }
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

  def set_editable_document
    @document = @project.documents.find_by_id(params[:id])
  end

  def redirect_without_document
    empty_response_or_root_path(project_documents_path) unless @document
  end

end
