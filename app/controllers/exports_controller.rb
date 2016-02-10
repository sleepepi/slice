# frozen_string_literal: true

class ExportsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_viewable_project,      only: [:index, :show, :new, :create, :file, :progress, :mark_unread, :destroy]
  before_action :redirect_without_project,  only: [:index, :show, :new, :create, :file, :progress, :mark_unread, :destroy]
  before_action :set_viewable_export,       only: [:show, :file, :mark_unread, :progress]
  before_action :set_editable_export,       only: [:destroy]
  before_action :redirect_without_export,   only: [:show, :file, :mark_unread, :progress, :destroy]

  def file
    if @export.file.size > 0
      send_file @export.zip_file_path
    else
      head :ok
    end
  end

  # POST /exports/1.js
  def progress
  end

  # GET /exports
  def index
    @order = scrub_order(Export, params[:order], 'exports.created_at DESC')
    @exports = current_user.all_viewable_exports.where(project_id: @project.id)
                           .search(params[:search]).order(@order)
                           .page(params[:page]).per(20)
  end

  # GET /exports/1
  def show
    @export.update viewed: true if @export.status == 'ready'
  end

  def new
    @export = current_user.exports.where(project_id: @project.id).new
  end

  def mark_unread
    @export.update viewed: false
    redirect_to project_exports_path(@project)
  end

  def create
    name = "#{@project.name.gsub(/[^a-zA-Z0-9_]/, '_')}_#{Time.zone.today.strftime('%Y%m%d')}"
    @export = current_user.exports.where(project_id: @project.id, name: name, total_steps: 1).create(export_params)
    @export.generate_export_in_background!

    if @export.new_record?
      redirect_to project_exports_path(@project)
    else
      redirect_to [@project, @export]
    end
  end

  # DELETE /exports/1
  def destroy
    @export.destroy
    redirect_to project_exports_path(@project)
  end

  private

  def set_viewable_export
    @export = current_user.all_viewable_exports.find_by_id(params[:id])
  end

  def set_editable_export
    @export = current_user.all_exports.find_by_id(params[:id])
  end

  def redirect_without_export
    empty_response_or_root_path(project_exports_path(@project)) unless @export
  end

  def export_params
    params.require(:export).permit(:include_csv_labeled, :include_csv_raw,
                                   :include_pdf, :include_files,
                                   :include_data_dictionary,
                                   :include_sas, :include_r)
  end
end
