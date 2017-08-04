# frozen_string_literal: true

json.event do
  json.extract!(@event, :id, :name, :slug)
end
json.design do
  json.extract!(@design, :id, :name, :slug)
end
json.sheet do
  json.partial! "api/v1/subjects/sheet", sheet: @sheet
end
