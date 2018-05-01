# frozen_string_literal: true

module Validation
  module Validators
    class ImperialHeight < Validation::Validators::Default
      MESSAGES = {
        blank: "",
        invalid: "Not a Valid Height",
        out_of_range: "Height Outside of Range",
        in_hard_range: "Height Outside of Soft Range",
        in_soft_range: ""
      }

      def messages
        MESSAGES
      end

      def blank_value?(value)
        value[:feet].blank? && value[:inches].blank?
      rescue
        true
      end

      def invalid_format?(value)
        !blank_value?(value) && !parse_imperial_height_from_hash(value)
      end

      def in_hard_range?(value)
        value_in_hard_range?(get_number(value))
      end

      def in_soft_range?(value)
        value_in_soft_range?(get_number(value))
      end

      def formatted_value(value)
        hash = parse_imperial_height_from_hash(value)
        f = (hash[:feet] == 1 ? I18n.t("sheets.foot") : I18n.t("sheets.feet"))
        i = (hash[:inches] == 1 ? I18n.t("sheets.inch") : I18n.t("sheets.inches"))
        "#{hash[:feet]} #{f} #{hash[:inches]} #{i}"
      rescue
        nil
      end

      def show_full_message?(_value)
        true
      end

      def response_to_value(response)
        if response.is_a?(Hash)
          parse_imperial_height_from_hash(response) || {}
        else
          parse_imperial_height(response) || {}
        end
      end

      def db_key_value_pairs(response)
        { value: parse_imperial_height_from_hash_to_s(response) }
      end

      private

      def get_number(value)
        value = response_to_value(value)
        value[:total_inches]
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
