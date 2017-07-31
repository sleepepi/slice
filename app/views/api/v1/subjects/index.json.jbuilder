# frozen_string_literal: true

json.array!(@subjects) do |subject|
  json.partial! "api/v1/subjects/subject", subject: subject
end
