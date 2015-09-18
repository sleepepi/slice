module Validation
  module Validators
    class SingleChoice < Validation::Validators::Default
      MESSAGES = {
        blank: '',
        in_soft_range: ''
      }

      def messages
        MESSAGES
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
