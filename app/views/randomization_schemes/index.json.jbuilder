json.array!(@randomization_schemes) do |randomization_scheme|
  json.extract! randomization_scheme, :id, :name, :description, :project_id, :user_id, :published, :randomization_goal, :deleted
  json.url randomization_scheme_url(randomization_scheme, format: :json)
end
