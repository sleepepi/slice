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

      def formatted_value(value)
        nil
      end

      def response_to_value(response)
        JSON.parse(response) rescue nil
      end

    end
  end
end
