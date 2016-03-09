# frozen_string_literal: true

# Allows project reports to be viewed by project owners, editors, viewers, and
# site editors and viewers.
class Reports::ProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_viewable_project_or_redirect

  # Concerns
  include Buildable

  def new_filter
    @design = @project.designs.find_by_id params[:design_id]
  end

  def edit_filter
    @variable = @project.variable_by_id params[:variable_id]
  end

  def filters
  end

  def reports
  end

  # GET /reports/projects/1/report
  # GET /reports/projects/1/report.csv
  # GET /reports/projects/1/report.pdf
  # POST /reports/projects/1/report.js
  def report
    params[:f] = [
      { id: 'design', axis: 'row', missing: '0' },
      { id: 'sheet_date', axis: 'col', missing: '0', by: params[:by] || 'month' }
    ]
    setup_report_new
    generate_table_csv_new if params[:format] == 'csv'
    generate_report_pdf if params[:format] == 'pdf'
  end

  # GET /projects/1/subject_report
  def subject_report
    @subjects = current_user.all_viewable_subjects
                            .where(project_id: @project.id).order(:subject_code)
                            .page(params[:page]).per(40)
    @designs = current_user.all_viewable_designs
                           .where(project_id: @project.id).order(:name)
  end

  private

  # Overwriting application_controller
  def find_viewable_project_or_redirect
    super(:id)
  end

  def redirect_without_project
    super(projects_path)
  end

  def generate_report_pdf
    pdf_location = generate_pdf_location
    if File.exist? pdf_location
      file_name = @report_title.gsub(' vs. ', ' versus ').gsub(/[^\da-zA-Z ]/, '')
      send_file pdf_location,
                filename: "#{file_name} #{Time.zone.now.strftime('%Y.%m.%d %Ih%M %p')}.pdf",
                type: 'application/pdf',
                disposition: 'inline'
    else
      redirect_to report_reports_project_path(@project), alert: 'Unable to generate PDF.'
    end
  end

  def generate_pdf_location
    orientation = %w(portrait landscape).include?(params[:orientation].to_s) ? params[:orientation].to_s : 'portrait'
    @design = @project.designs.new(name: 'Summary Report')
    @design.latex_report_new_file_location(
      current_user, orientation, @report_title, @report_subtitle,
      @report_caption, @percent, @table_header, @table_body, @table_footer
    )
  end
end
