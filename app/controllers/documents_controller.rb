# frozen_string_literal: true

# Allows supporting documents to be uploaded alongside a project.
class DocumentsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_viewable_project_or_redirect, only: [:file]
  before_action :find_editable_project_or_redirect, only: [:index, :show, :new, :edit, :create, :update, :destroy]
  before_action :find_document_or_redirect, only: [:file, :show, :edit, :update, :destroy]

  def file
    if @document.file.size > 0
      send_file File.join(CarrierWave::Uploader::Base.root, @document.file.url)
    else
      render nothing: true
    end
  end

  # GET /documents
  def index
    @order = scrub_order(Document, params[:order], 'documents.name')
    @documents = @project.documents.search(params[:search]).order(@order).page(params[:page]).per(20)
  end

  # GET /documents/1
  def show
  end

  # GET /documents/new
  def new
    @document = @project.documents.new
  end

  # GET /documents/1/edit
  def edit
  end

  # POST /documents
  def create
    @document = current_user.documents.where(project_id: @project.id).new(document_params)
    if @document.save
      redirect_to [@document.project, @document], notice: 'Document was successfully created.'
    else
      render :new
    end
  end

  # PATCH /documents/1
  def update
    original_category = @document.category
    if @document.update(document_params)
      @project.documents.where(category: original_category)
              .update_all(category: @document.category) if params[:rename_category] == '1'
      redirect_to [@document.project, @document], notice: 'Document was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /documents/1
  def destroy
    @document.destroy
    redirect_to project_documents_path(@project)
  end

  private

  def find_document_or_redirect
    @document = @project.documents.find_by_id params[:id]
    redirect_without_document
  end

  def redirect_without_document
    empty_response_or_root_path(project_documents_path(@project)) unless @document
  end

  def document_params
    params.require(:document).permit(
      :name, :category, :file, :file_cache, :archived
    )
  end
end
