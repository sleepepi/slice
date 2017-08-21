# frozen_string_literal: true

module Slicers
  # Provides default methods for checking variables and saving to database.
  class RadioSlicer < DefaultSlicer
    def format_for_db_update(value)
      domain_option = @variable.domain_options.find_by(value: value)
      if domain_option
        { value: nil, domain_option_id: domain_option.id }
      else
        { value: value, domain_option_id: nil }
      end
    end
  end
end
