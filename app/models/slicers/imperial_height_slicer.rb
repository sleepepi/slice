# frozen_string_literal: true

module Slicers
  # Provides default methods for checking variables and saving to database.
  class ImperialHeightSlicer < DefaultSlicer
    include DateAndTimeParser

    def format_for_db_update(value)
      { value: parse_imperial_height_from_hash_to_s(value) }
    end
  end
end
