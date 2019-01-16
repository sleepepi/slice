# frozen_string_literal: true

# Allows reporters and review admins to manage and view supporting documents.
class AeModule::DocumentsController < AeModule::BaseController
  before_action :find_project_as_reporter_or_admin_or_team_member_or_redirect, only: [:index, :show, :download]
  before_action :find_review_admin_project_or_reporter_project_or_redirect, except: [:index, :show, :download]
  before_action :redirect_blinded_users
  before_action :find_adverse_event_or_redirect
  before_action :find_ae_document_or_redirect, only: [
    :show, :edit, :update, :destroy, :download
  ]
  before_action :set_project_member
  layout :sidebar_layout

  # GET /projects/:project_id/ae-module/adverse-events/:adverse_event_id/documents
  def index
    scope = @adverse_event.ae_documents.search_any_order(params[:search])
    @documents = scope_order(scope).page(params[:page]).per(AeAdverseEvent::DOCS_PER_PAGE)
  end

  # GET /ae_module/documents/:id
  def show
  end

  # GET /projects/:project_id/ae_module/adverse-events/:adverse_event_id/documents/:id/download
  def download
    if @document.pdf? && params[:disposition] == "inline"
      send_file_if_present @document.file, type: "application/pdf", disposition: "inline"
    else
      send_file_if_present @document.file
    end
  end

  # GET /ae_module/documents/new
  def new
    @document = AeDocument.new
  end

  # # GET /ae_module/documents/:id/edit
  # def edit
  # end

  # POST /ae_module/documents
  def create
    @document = @adverse_event.ae_documents.where(project: @project, user: current_user).new(ae_document_params)

    if @document.save
      @document.uploaded!(current_user)
      redirect_to ae_module_documents_path(@project, @adverse_event), notice: "Document was successfully created."
    else
      render :new
    end
  end

  # POST /projects/:project_id/ae_module/adverse-events/:adverse_event_id/documents/upload-files
  def upload_files
    @adverse_event.attach_files!(params[:files], current_user)
    params[:order] = "latest"
    @documents = scope_order(@adverse_event.ae_documents).page(params[:page]).per(AeAdverseEvent::DOCS_PER_PAGE)
    render :index
  end

  # DELETE /ae_module/documents/1
  def destroy
    @document.removed!(current_user)
    @document.destroy
    redirect_to ae_module_documents_path(@project, @adverse_event), notice: "Document was successfully destroyed."
  end

  private

  def find_review_admin_project_or_reporter_project_or_redirect
    project = Project.current.find_by_param(params[:project_id])
    if project.ae_admin?(current_user)
      @project = project
    elsif project.ae_reporter?(current_user)
      @project = project
    else
      redirect_without_project
    end
  end

  def find_ae_document_or_redirect
    @document = @adverse_event.ae_documents.find_by(id: params[:id])
    empty_response_or_root_path(ae_module_adverse_event_path(@project, @adverse_event)) unless @adverse_event
  end

  def ae_document_params
    params[:ae_document] ||= { blank: "1" }
    if params[:ae_document][:file].present?
      params[:ae_document][:byte_size] = params[:ae_document][:file].size
      if params[:ae_document][:file].original_filename.present?
        params[:ae_document][:filename] = params[:ae_document][:file].original_filename
        params[:ae_document][:content_type] = AeDocument.content_type(params[:ae_document][:file].original_filename)
      end
    end
    params.require(:ae_document).permit(:file, :byte_size, :filename, :content_type)
  end

  def scope_order(scope)
    @order = params[:order]
    scope.order(Arel.sql(AeDocument::ORDERS[params[:order]] || AeDocument::DEFAULT_ORDER))
  end
end
