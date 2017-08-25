json.extract!(
  sheet,
  :id,
  :name,
  :project_id,
  :design_id,
  :subject_id,
  :subject_event_id,
  :authentication_token,
  :response_count,
  :total_response_count,
  :percent,
  :missing,
  :created_at,
  :updated_at
)
json.design_slug sheet.design.slug