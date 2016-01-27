# frozen_string_literal: true

module Validation
  module Validators
    class Numeric < Validation::Validators::Default
      MESSAGES = {
        blank: '',
        invalid: 'Not a Valid Number',
        out_of_range: 'Number Outside of Range',
        in_hard_range: 'Number Outside of Soft Range',
        in_soft_range: ''
      }

      def messages
        MESSAGES
      end

      def message(value)
        option = @variable.shared_options.select { |o| o[:value] == value.to_s }.first
        if in_missing_codes?(value) && option
          "#{option[:value]}: #{option[:name]}"
        else
          messages[status(value).to_sym]
        end
      end

      def invalid_format?(value)
        !blank_value?(value) && !get_number(value)
      end

      def in_hard_range?(value)
        value_in_hard_range?(get_number(value)) || in_missing_codes?(value)
      end

      def in_soft_range?(value)
        value_in_soft_range?(get_number(value)) || in_missing_codes?(value)
      end

      def formatted_value(value)
        if in_missing_codes?(value)
          ""
        else
          "#{value}#{" #{variable.units}" unless variable.units.blank?}" unless value.blank?
        end
      end

      def show_full_message?(value)
        message(value) != ''
      end

    private

      def get_number(value)
        string_response = "%g" % value
        begin
          Integer(string_response)
        rescue
          Float(string_response)
        end
      rescue
        nil
      end

      def value_in_hard_range?(number)
        less_or_equal_to?(number, @variable.hard_maximum) && greater_than_or_equal_to?(number, @variable.hard_minimum)
      end

      def value_in_soft_range?(number)
        less_or_equal_to?(number, @variable.soft_maximum) && greater_than_or_equal_to?(number, @variable.soft_minimum)
      end

      def less_or_equal_to?(number, number_max)
        !number || !number_max || (number_max && number <= number_max)
      end

      def greater_than_or_equal_to?(number, number_min)
        !number || !number_min || (number_min && number >= number_min)
      end

      def in_missing_codes?(value)
        @variable.missing_codes.include?(value.to_s)
      end
    end
  end
end
