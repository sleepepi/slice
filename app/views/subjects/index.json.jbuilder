json.array!(@subjects) do |subject|
  json.partial! 'subjects/subject', subject: subject

  json.path project_subject_path(subject.project, subject, format: :json)
  # json.url project_subject_url(subject.project, subject, format: :json)
end
