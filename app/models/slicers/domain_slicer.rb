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
      log_non_string("left", left)
      log_non_string("right", right)
      # Else check if they are equal as numbers if both are formatted as numbers.
      decimal_regex = Regexp.new(/^[-+]?[0-9]*(\.)?[0-9]+$/)
      if !(decimal_regex =~ left.to_s).nil? && !(decimal_regex =~ right.to_s).nil?
        return Float(left.to_s) == Float(right.to_s)
      else
        return false
      end
    end

    private

    def log_non_string(name, value)
      return if value.is_a?(String)
      Rails.logger.debug "Unexpected non-string class in equal_strings_or_numbers?, #{name}: #{value.class} #{value}"
    end
  end
end
