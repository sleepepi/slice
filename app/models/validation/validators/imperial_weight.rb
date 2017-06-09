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
          response[:pounds] = parse_integer(response[:pounds])
          response[:ounces] = parse_integer(response[:ounces])
          response
        else
          weight = parse_imperial_weight(response)
          (weight ? { pounds: weight[:pounds], ounces: weight[:ounces] } : {})
        end
      end

      def db_key_value_pairs(response)
        { value: parse_imperial_weight_from_hash_to_s(response) }
      end
    end
  end
end
