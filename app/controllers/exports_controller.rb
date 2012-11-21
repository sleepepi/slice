class ExportsController < ApplicationController
  before_filter :authenticate_user!

  # GET /exports
  # GET /exports.json
  def index
    export_scope = current_user.all_viewable_exports
    @order = scrub_order(Export, params[:order], "exports.created_at DESC")
    export_scope = export_scope.order(@order)
    @export_count = export_scope.count
    @exports = export_scope.page(params[:page]).per( 20 )

    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.json { render json: @exports }
    end
  end

  # GET /exports/1
  # GET /exports/1.json
  def show
    @export = current_user.all_viewable_exports.find_by_id(params[:id])

    respond_to do |format|
      if @export
        @export.update_attribute :viewed, true if @export.status == 'ready'
        format.html # show.html.erb
        format.json { render json: @export }
      else
        format.html { redirect_to exports_path }
        format.json { head :no_content }
      end
    end
  end

  def mark_unread
    @export = current_user.all_viewable_exports.find_by_id(params[:id])

    respond_to do |format|
      if @export
        @export.update_attribute :viewed, false
        format.html { redirect_to exports_path }
        format.json { render json: @export }
      else
        format.html { redirect_to exports_path }
        format.json { head :no_content }
      end
    end
  end

  # # GET /exports/new
  # # GET /exports/new.json
  # def new
  #   @export = current_user.exports.new

  #   respond_to do |format|
  #     format.html # new.html.erb
  #     format.json { render json: @export }
  #   end
  # end

  # # GET /exports/1/edit
  # def edit
  #   @export = current_user.all_exports.find_by_id(params[:id])
  #   redirect_to root_path unless @export
  # end

  # # POST /exports
  # # POST /exports.json
  # def create
  #   @export = current_user.exports.new(post_params)

  #   respond_to do |format|
  #     if @export.save
  #       format.html { redirect_to @export, notice: 'Export was successfully created.' }
  #       format.json { render json: @export, status: :created, location: @export }
  #     else
  #       format.html { render action: "new" }
  #       format.json { render json: @export.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # # PUT /exports/1
  # # PUT /exports/1.json
  # def update
  #   @export = current_user.all_exports.find_by_id(params[:id])

  #   respond_to do |format|
  #     if @export
  #       if @export.update_attributes(post_params)
  #         format.html { redirect_to @export, notice: 'Export was successfully updated.' }
  #         format.json { head :no_content }
  #       else
  #         format.html { render action: "edit" }
  #         format.json { render json: @export.errors, status: :unprocessable_entity }
  #       end
  #     else
  #       format.html { redirect_to root_path }
  #       format.json { head :no_content }
  #     end
  #   end
  # end

  # DELETE /exports/1
  # DELETE /exports/1.json
  def destroy
    @export = current_user.all_exports.find_by_id(params[:id])
    @export.destroy if @export

    respond_to do |format|
      format.html { redirect_to exports_path }
      format.json { head :no_content }
    end
  end

  private

  # def post_params
  #   params[:export] ||= {}

  #   params[:export].slice(
  #     :name, :export_type, :include_files, :status, :file, :project_id, :viewed
  #   )
  # end
end
