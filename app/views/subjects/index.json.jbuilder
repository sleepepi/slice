json.array!(@subjects) do |subject|
  json.extract! subject, :project_id, :subject_code, :user_id, :site_id, :acrostic, :email, :status, :created_at, :updated_at
  json.path project_subject_path(subject.project, subject, format: :json)
  # json.url project_subject_url(subject.project, subject, format: :json)
end
