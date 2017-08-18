# frozen_string_literal: true

json.name @design.name

json.event do
  json.extract!(@event, :id, :name, :slug)
end
json.design do
  json.extract!(@design, :id, :name, :slug)
  json.pages_count @design.design_options.count
end
json.sheet do
  json.partial! "api/v1/subjects/sheet", sheet: @sheet
end
