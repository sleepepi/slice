# frozen_string_literal: true

# Allows files to be attached and removed from adverse events
class AdverseEventFilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_viewable_project, only: [:index, :show, :download]
  before_action :set_editable_project_or_editable_site, only: [:new, :create, :create_multiple, :destroy]
  before_action :redirect_without_project
  before_action :set_adverse_event
  before_action :set_adverse_event_file, only: [:show, :download, :destroy]

  # GET /adverse-events/:adverse_event_id/files
  def index
    @adverse_event_files = @adverse_event.adverse_event_files
  end

  # GET /adverse-events/:adverse_event_id/files/new
  def new
    @adverse_event_file = @adverse_event.adverse_event_files.new
  end

  # POST /adverse-events/:adverse_event_id/files
  def create
    @adverse_event_file = current_user.adverse_event_files
                                      .where(project_id: @project.id, adverse_event_id: @adverse_event.id)
                                      .new(adverse_event_file_params)
    if @adverse_event_file.save
      message = 'File was successfully attached.'
      redirect_to project_adverse_event_adverse_event_files_path(@project, @adverse_event), notice: message
    else
      render :new
    end
  end

  # POST /adverse-events/:adverse_event_id/files/upload.js
  def create_multiple
    params[:attachments].each do |attachment|
      current_user.adverse_event_files
                  .where(project_id: @project.id, adverse_event_id: @adverse_event.id)
                  .create(attachment: attachment)
    end
    render :index
  end

  def download
    if @adverse_event_file.pdf?
      send_file File.join(CarrierWave::Uploader::Base.root, @adverse_event_file.attachment.url),
                type: 'application/pdf', disposition: 'inline'
    else
      send_file File.join(CarrierWave::Uploader::Base.root, @adverse_event_file.attachment.url)
    end
  end

  # DELETE /adverse-events/:adverse_event_id/files/1
  def destroy
    @adverse_event_file.destroy
    message = 'File was successfully deleted.'
    redirect_to project_adverse_event_adverse_event_files_path(@project, @adverse_event), notice: message
  end

  private

  def set_adverse_event
    @adverse_event = current_user.all_viewable_adverse_events.find_by_id params[:adverse_event_id]
    redirect_without_adverse_event
  end

  def redirect_without_adverse_event
    empty_response_or_root_path(project_adverse_events_path(@project)) unless @adverse_event
  end

  def set_adverse_event_file
    @adverse_event_file = @adverse_event.adverse_event_files.find_by_id params[:id]
    redirect_without_adverse_event_file
  end

  def redirect_without_adverse_event_file
    redirect_path = project_adverse_event_adverse_event_files_path(@project, @adverse_event)
    empty_response_or_root_path(redirect_path) unless @adverse_event_file
  end

  def adverse_event_file_params
    params.require(:adverse_event_file).permit(:attachment)
  end
end
