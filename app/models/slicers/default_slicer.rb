# frozen_string_literal: true

module Slicers
  # Provides default methods for checking variables and saving to database.
  class DefaultSlicer
    def initialize(variable)
      @variable = variable
    end

    def format_for_db_update(value)
      { value: value }
    end
  end
end
