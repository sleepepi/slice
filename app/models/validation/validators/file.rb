module Validation
  module Validators
    class File < Validation::Validators::Numeric

      MESSAGES = {
        blank: '',
        invalid: 'Not a Valid File',
        in_soft_range: ''
      }

      def messages
        MESSAGES
      end

      def blank_value?(value)
        value.blank?
      end

      def formatted_value(value)
        nil
      end

    end
  end
end
