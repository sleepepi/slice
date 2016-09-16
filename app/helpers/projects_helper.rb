# frozen_string_literal: true

# Helps menu open appropriate sections
module ProjectsHelper
  def viewing_main_project?
    true # !viewing_reports? && !viewing_project_setup?
  end

  def viewing_reports?
    current_page?(reports_reports_project_path(@project)) ||
      current_page?(subject_report_reports_project_path(@project))
  end

  def viewing_project_setup?
    true
  end
end
