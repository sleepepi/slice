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

      # This is not used by multiple choice
      def db_key_value_pairs(response)
        {}
      end

      def store_temp_response(in_memory_sheet_variable, response)
        in_memory_sheet_variable.responses = self.response_to_value(response).collect{|value| Validation::InMemoryResponse.new(value)}
        in_memory_sheet_variable
      end

    end
  end
end
