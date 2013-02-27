json.array!(@sheets) do |sheet|
  json.extract! sheet, :design_id, :project_id, :subject_id, :variable_ids, :last_user_id, :last_viewed_by_id, :last_viewed_at, :user_id, :last_edited_at, :created_at, :updated_at
  json.path project_sheet_path(sheet.project, sheet, format: :json)
  # json.url project_sheet_url(sheet.project, sheet, format: :json)
end
