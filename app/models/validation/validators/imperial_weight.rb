# frozen_string_literal: true

module Validation
  module Validators
    class ImperialWeight < Validation::Validators::Default
      MESSAGES = {
        blank: "",
        invalid: "Not a Valid Weight",
        out_of_range: "Weight Outside of Range",
        in_hard_range: "Weight Outside of Soft Range",
        in_soft_range: ""
      }

      def messages
        MESSAGES
      end

      def blank_value?(value)
        value[:pounds].blank? && value[:ounces].blank?
      rescue
        true
      end

      def invalid_format?(value)
        !blank_value?(value) && !parse_imperial_weight_from_hash(value)
      end

      def in_hard_range?(value)
        value_in_hard_range?(get_number(value))
      end

      def in_soft_range?(value)
        value_in_soft_range?(get_number(value))
      end

      def formatted_value(value)
        hash = parse_imperial_weight_from_hash(value)
        p = (hash[:pounds] == 1 ? "pound" : "pounds")
        o = (hash[:ounces] == 1 ? "ounce" : "ounces")
        "#{hash[:pounds]} #{p} #{hash[:ounces]} #{o}"
      rescue
        nil
      end

      def show_full_message?(_value)
        true
      end

      def response_to_value(response)
        if response.is_a?(Hash)
          parse_imperial_weight_from_hash(response) || {}
        else
          parse_imperial_weight(response) || {}
        end
      end

      def db_key_value_pairs(response)
        { value: parse_imperial_weight_from_hash_to_s(response) }
      end

      private

      def get_number(value)
        value = response_to_value(value)
        value[:total_ounces]
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
    end
  end
end
