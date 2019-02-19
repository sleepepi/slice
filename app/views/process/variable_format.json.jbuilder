# frozen_string_literal: true

json.value do
  json.raw params[:value]
  json.formatted @formatted_value
end
