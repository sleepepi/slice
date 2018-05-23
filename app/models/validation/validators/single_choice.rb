# frozen_string_literal: true

module Validation
  module Validators
    class SingleChoice < Validation::Validators::Default
      def messages
        {
          blank: "",
          in_soft_range: ""
        }
      end

      def blank_value?(value)
        value.blank?
      end

      def formatted_value(_value)
        nil
      end
    end
  end
end
