# frozen_string_literal: true

json.event do
  json.partial! "api/v1/projects/event", event: @event if @event
end

json.design do
  json.partial! "api/v1/projects/design", design: @design if @design
end
