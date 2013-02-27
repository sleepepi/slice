class ReportsController < ApplicationController
  before_action :authenticate_user!

  def index
  end

  # POST /reports
  # POST /reports.json
  def create
    @report = current_user.reports.new(post_params)

    respond_to do |format|
      if @report.save
        format.js # .html { redirect_to @report, notice: 'report was successfully created.' }
        format.json { render json: @report, status: :created, location: @report }
      else
        format.js # .html { render action: "new" }
        format.json { render json: @report.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    @report = current_user.all_viewable_reports.find_by_id(params[:id])
    @design = current_user.all_viewable_designs.find_by_id(@report.options[:design_id]) if @report

    respond_to do |format|
      if @report and @design
        format.html do
          redirect_to report_project_design_path(@design.project, @design, @report.options.except(:design_id))
        end
        format.json { render json: @report }
      else
        format.html { redirect_to reports_path }
        format.json { head :no_content }
      end
    end
  end

  # DELETE /reports/1
  # DELETE /reports/1.json
  def destroy
    @report = current_user.all_reports.find_by_id(params[:id])
    @report.destroy if @report

    respond_to do |format|
      format.js { render 'destroy' }
      format.json { head :no_content }
    end
  end

  private

  def post_params
    params[:report] ||= {}

    params[:report].slice(
      :name, :options
    )
  end

end
