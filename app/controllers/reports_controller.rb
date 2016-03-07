# frozen_string_literal: true

# Stores custom reports for users
class ReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_viewable_report_or_redirect, only: [:show]

  def index
  end

  # POST /reports.js
  def create
    @report = current_user.reports.new(report_params)
    @report.save
  end

  # GET /reports/1
  def show
    @design = current_user.all_viewable_designs.find_by_param(@report.options[:design_id])
    if @design
      redirect_to project_reports_design_advanced_path(@design.project, @design, @report.options.except(:design_id))
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

  def find_viewable_report_or_redirect
    @report = current_user.all_viewable_reports.find_by_id params[:id]
    redirect_without_report
  end

  def redirect_without_report
    redirect_to reports_path unless @report
  end

  def report_params
    params[:report] ||= {}

    params.require(:report).permit!
    # TODO: Permit Hash (options)
    # (:name, :options)
  end
end
