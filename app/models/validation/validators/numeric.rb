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

      def invalid_format?(value)
        (!blank_value?(value) and !get_number(value))
      end

      def in_hard_range?(value)
        value_in_hard_range?(get_number(value))
      end

      def in_soft_range?(value)
        value_in_soft_range?(get_number(value))
      end

      def formatted_value(value)
        "#{value}#{" #{variable.units}" unless variable.units.blank?}" unless value.blank?
      end

    private

      def get_number(value)
        begin
          string_response = "%g" % value
          begin
            Integer(string_response)
          rescue
            Float(string_response)
          end
        rescue
          nil
        end
      end

      def value_in_hard_range?(number)
        less_or_equal_to?(number, @variable.hard_maximum) and greater_than_or_equal_to?(number, @variable.hard_minimum)
      end

      def value_in_soft_range?(number)
        less_or_equal_to?(number, @variable.soft_maximum) and greater_than_or_equal_to?(number, @variable.soft_minimum)
      end

      def less_or_equal_to?(number, number_max)
        !number or !number_max or (number_max and number <= number_max)
      end

      def greater_than_or_equal_to?(number, number_min)
        !number or !number_min or (number_min and number >= number_min)
      end

    end
  end
end
