json.array!(@events) do |event|
  json.extract! event, :name, :description, :project_id, :user_id, :deleted
  # json.url event_url(event, format: :json)
end
