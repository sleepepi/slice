module Validation
  module Validators
    class Signature < Validation::Validators::Default
      MESSAGES = {
        blank: '',
        invalid: 'Not a Valid Signature'
      }

      def messages
        MESSAGES
      end

      def blank_value?(value)
        get_signature(value) == []
      end

      def formatted_value(_value)
        nil
      end

      def response_to_value(response)
        JSON.parse(response)
      rescue
        nil
      end

    private

      def get_signature(value)
        if value.is_a?(Array)
          value
        else
          begin
            JSON.parse(value)
          rescue
            []
          end
        end
      end
    end
  end
end
