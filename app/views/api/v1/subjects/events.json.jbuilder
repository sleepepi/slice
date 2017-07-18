# frozen_string_literal: true

json.array!(@subject.subject_events) do |subject_event|
  json.partial! "api/v1/subjects/subject_event", subject_event: subject_event
end
