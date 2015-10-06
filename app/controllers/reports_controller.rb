# Stores custom reports for users
class ReportsController < ApplicationController
  before_action :authenticate_user!

  def index
  end

  # POST /reports.js
  def create
    @report = current_user.reports.new(report_params)
    @report.save
  end

  # GET /reports
  def show
    @report = current_user.all_viewable_reports.find_by_id params[:id]
    @design = current_user.all_viewable_designs.find_by_id(@report.options[:design_id]) if @report

    if @report && @design
      redirect_to report_project_design_path(@design.project, @design, @report.options.except(:design_id))
    else
      redirect_to reports_path
    end
  end

  # DELETE /reports/1.js
  def destroy
    @report = current_user.all_reports.find_by_id params[:id]
    @report.destroy if @report
  end

  private

  def report_params
    params[:report] ||= {}

    params.require(:report).permit!
    # TODO: Permit Hash (options)
    #(
    #  :name, :options
    #)
  end
end
