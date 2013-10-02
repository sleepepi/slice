json.array!(@schedules) do |schedule|
  json.extract! schedule, :name, :description, :items, :project_id, :user_id, :deleted
  json.url schedule_url(schedule, format: :json)
end
