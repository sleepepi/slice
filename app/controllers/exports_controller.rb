class ExportsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_viewable_project, only: [ :index, :show, :progress, :mark_unread, :destroy ]
  before_action :redirect_without_project, only: [ :index, :show, :progress, :mark_unread, :destroy ]
  before_action :set_viewable_export, only: [ :show, :mark_unread, :progress ]
  before_action :set_editable_export, only: [ :destroy ]
  before_action :redirect_without_export, only: [ :show, :mark_unread, :progress, :destroy ]

  # POST /exports/1.js
  def progress
  end

  # GET /exports
  # GET /exports.json
  def index
    @order = scrub_order(Export, params[:order], "exports.created_at DESC")
    @exports = current_user.all_viewable_exports.where(project_id: @project.id).filter(params).search(params[:search]).order(@order).page(params[:page]).per( 20 )
  end

  # GET /exports/1
  # GET /exports/1.json
  def show
    @export.update viewed: true if @export.status == 'ready'
  end

  def mark_unread
    @export.update viewed: false

    respond_to do |format|
      format.html { redirect_to project_exports_path(@project) }
      format.json { render json: @export }
    end
  end

  # DELETE /exports/1
  # DELETE /exports/1.json
  def destroy
    @export.destroy

    respond_to do |format|
      format.html { redirect_to project_exports_path(@project) }
      format.json { head :no_content }
    end
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

    # def export_params
    #   params.require(:export).permit(
    #     :name, :include_files, :status, :file, :project_id, :viewed
    #   )
    # end

end
