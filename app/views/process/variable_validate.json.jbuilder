# frozen_string_literal: true

json.extract! @variable.value_in_range?(params[:value]), :status, :message, :formatted_value, :raw_value
