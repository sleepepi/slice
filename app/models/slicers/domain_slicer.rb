# frozen_string_literal: true

module Slicers
  # Provides default methods for checking variables and saving to database.
  class DomainSlicer < DefaultSlicer
    def format_for_db_update(value)
      domain_option = domain_options.find { |option| equal_strings_or_numbers?(option.value, value) }
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

    def equal_strings_or_numbers?(left, right)
      # Return true if the strings are equal.
      return true if left.to_s == right.to_s
      # Else check if they are equal as numbers if both are formatted as numbers.
      decimal_regex = Regexp.new(/^[-+]?[0-9]*(\.[0-9]+)?$/)
      if !(decimal_regex =~ left).nil? && !(decimal_regex =~ right).nil?
        return Float(left) == Float(right)
      else
        return false
      end
    end
  end
end
