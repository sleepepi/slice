# frozen_string_literal: true

module Validation
  module Validators
    class Default
      include DateAndTimeParser

      MESSAGES = {
        blank: '',
        invalid: 'Not a Valid Value',
        out_of_range: 'Value Out of Range',
        in_hard_range: 'Value Outside of Soft Range',
        in_soft_range: ''
      }

      attr_reader :variable

      def initialize(variable)
        @variable = variable
      end

      def value_in_range?(value)
        { status: status(value), message: message(value), formatted_value: formatted_value(value) }
      end

      def blank_value?(value)
        value.blank?
      end

      def invalid_format?(_value)
        false
      end

      def in_hard_range?(_value)
        true
      end

      def out_of_range?(value)
        !in_hard_range?(value)
      end

      def in_soft_range?(_value)
        true
      end

      def formatted_value(value)
        value.to_s
      end

      def show_full_message?(_value)
        false
      end

      def response_to_value(response)
        response
      end

      def status(value)
        if blank_value?(value)
          'blank'
        elsif invalid_format?(value)
          'invalid'
        elsif out_of_range?(value)
          'out_of_range'
        elsif in_soft_range?(value)
          'in_soft_range'
        else
          'in_hard_range'
        end
      end

      def message(value)
        messages[status(value).to_sym]
      end

      def messages
        MESSAGES
      end

      def db_key_value_pairs(response)
        { response: response }
      end

      def store_temp_response(in_memory_sheet_variable, response)
        db_key_value_pairs(response).each do |key, db_formatted_value|
          in_memory_sheet_variable.send("#{key}=", db_formatted_value) if in_memory_sheet_variable.respond_to?("#{key}=")
        end
        in_memory_sheet_variable
      end
    end
  end
end
