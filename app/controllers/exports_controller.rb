# frozen_string_literal: true

# Allows a user to manage project data exports.
class ExportsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_viewable_project_or_redirect
  before_action :find_viewable_export_or_redirect, only: [:show, :file, :mark_unread, :progress]
  before_action :find_editable_export_or_redirect, only: [:destroy]

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
    @order = scrub_order(Export, params[:order], 'exports.created_at desc')
    @exports = viewable_exports.search(params[:search]).order(@order)
                               .page(params[:page]).per(20)
    redirect_to new_project_export_path(@project) if viewable_exports.count == 0
  end

  # GET /exports/1
  def show
    @export.update viewed: true if @export.status == 'ready'
  end

  # GET /exports/new
  def new
    @last_export = current_user.exports.where(project_id: @project.id).last
    @export = current_user.exports.where(project_id: @project.id).new
    if @last_export
      @export.include_csv_labeled = @last_export.include_csv_labeled
      @export.include_csv_raw = @last_export.include_csv_raw
      @export.include_sas = @last_export.include_sas
      @export.include_r = @last_export.include_r
      @export.include_pdf = @last_export.include_pdf
      @export.include_files = @last_export.include_files
      @export.include_data_dictionary = @last_export.include_data_dictionary
      @export.include_adverse_events = @last_export.include_adverse_events
      @export.include_randomizations = @last_export.include_randomizations
    end
  end

  # POST /exports/1/mark_unread
  def mark_unread
    @export.update viewed: false
    redirect_to project_exports_path(@project)
  end

  # POST /exports
  def create
    @export = current_user.exports
                          .where(project_id: @project.id, name: export_name, total_steps: 1)
                          .create(export_params)
    @export.generate_export_in_background!
    redirect_to [@project, @export]
  end

  # DELETE /exports/1
  def destroy
    @export.destroy
    redirect_to project_exports_path(@project)
  end

  private

  def viewable_exports
    current_user.all_viewable_exports.where(project_id: @project.id)
  end

  def find_viewable_export_or_redirect
    @export = viewable_exports.find_by_id params[:id]
    redirect_without_export
  end

  def find_editable_export_or_redirect
    @export = current_user.all_exports.where(project_id: @project.id).find_by_id params[:id]
    redirect_without_export
  end

  def redirect_without_export
    empty_response_or_root_path(project_exports_path(@project)) unless @export
  end

  def export_params
    params.require(:export).permit(
      :include_csv_labeled, :include_csv_raw, :include_pdf, :include_files,
      :include_data_dictionary, :include_sas, :include_r,
      :include_adverse_events, :include_randomizations
    )
  end

  def export_name
    "#{@project.name.gsub(/[^a-zA-Z0-9_]/, '_')}_#{Time.zone.today.strftime('%Y%m%d')}"
  end
end
