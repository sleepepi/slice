# frozen_string_literal: true

module Validation
  module Validators
    class File < Validation::Validators::Numeric
      MESSAGES = {
        blank: "",
        invalid: "Not a Valid File",
        in_soft_range: ""
      }

      def messages
        MESSAGES
      end

      def blank_value?(value)
        value.blank?
      end

      def invalid_format?(_value)
        false
      end

      def out_of_range?(_value)
        false
      end

      def formatted_value(_value)
        nil
      end

      def db_key_value_pairs(response)
        if response.is_a?(Hash)
          response
        else
          {}
        end
      end
    end
  end
end
