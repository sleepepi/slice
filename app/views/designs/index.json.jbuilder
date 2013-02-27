json.array!(@designs) do |design|
  json.extract! design, :description, :name, :options, :project_id, :email_template, :email_subject_template, :updater_id, :csv_file, :created_at, :updated_at
  json.path project_design_path(design.project, design, format: :json)
  # json.url project_design_url(design.project, design, format: :json)
end
