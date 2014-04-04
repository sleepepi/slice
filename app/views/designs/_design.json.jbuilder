json.extract! design, :description, :name, :project_id, :updater_id, :csv_file, :created_at, :updated_at

json.options do
  json.array!(design.options) do |option|
    json.partial! 'designs/option', option: option
  end
end
