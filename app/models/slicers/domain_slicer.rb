# frozen_string_literal: true

module Slicers
  # Provides default methods for checking variables and saving to database.
  class DomainSlicer < DefaultSlicer
    def format_for_db_update(value)
      domain_option = domain_options.find { |option| option.value == value.to_s }
      if domain_option
        { value: nil, domain_option_id: domain_option.id }
      else
        { value: value, domain_option_id: nil }
      end
    end

    def domain_options
      @domain_options ||= begin
        @variable.domain_options.to_a
      end
    end
  end
end
