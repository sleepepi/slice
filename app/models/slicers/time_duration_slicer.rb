# frozen_string_literal: true

module Slicers
  # Provides default methods for checking variables and saving to database.
  class TimeDurationSlicer < DefaultSlicer
    include DateAndTimeParser

    def format_for_db_update(value)
      { value: parse_time_duration_from_hash_to_s(value, no_hours: @variable.no_hours?) }
    end
  end
end
