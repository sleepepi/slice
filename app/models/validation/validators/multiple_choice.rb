module Validation
  module Validators
    class MultipleChoice < Validation::Validators::Default
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

      def formatted_value(value)
        nil
      end

      def response_to_value(response)
        response.collect(&:to_s).reject(&:blank?) rescue response = []
      end

    end
  end
end
