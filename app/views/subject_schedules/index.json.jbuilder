json.array!(@subject_schedules) do |subject_schedule|
  json.extract! subject_schedule, :subject_id, :schedule_id, :initial_due_date
  json.url subject_schedule_url(subject_schedule, format: :json)
end
