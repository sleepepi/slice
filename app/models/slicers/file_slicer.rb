# frozen_string_literal: true

module Slicers
  # Provides default methods for checking variables and saving to database.
  class FileSlicer < DefaultSlicer
    def format_for_db_update(value)
      if value.present?
        value
      else
        {}
      end
    end
  end
end
