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

      def invalid_format?(value)
        false
      end

      def out_of_range?(value)
        false
      end

      def formatted_value(value)
        nil
      end

      def db_key_value_pairs(response)
        if response.kind_of?(Hash)
          response
        else
          {}
        end
      end

    end
  end
end
