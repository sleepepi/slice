json.extract! subject, :project_id, :subject_code, :user_id, :site_id, :acrostic, :email, :status, :created_at, :updated_at

json.subject_schedules subject.subject_schedules.order(:initial_due_date).each do |subject_schedule|
  json.partial! 'subject_schedules/subject_schedule', subject_schedule: subject_schedule
end
