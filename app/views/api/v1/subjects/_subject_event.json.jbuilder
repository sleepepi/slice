# frozen_string_literal: true

json.extract! subject_event, :id, :name, :event_id, :event_date, :unblinded_responses_count, :unblinded_questions_count, :unblinded_percent

json.subject_events do
  json.array!(subject_event.event.event_designs.includes(:design)) do |event_design|
    json.extract! event_design.design, :name
    sheets = @subject.sheets.where(subject_event: subject_event, design: event_design.design)
    json.sheets do
      json.array!(sheets) do |sheet|
        json.extract! sheet, :id, :name, :response_count, :total_response_count, :percent, :missing, :authentication_token
      end
    end
  end
end
