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

      def invalid_format?(value)
        false
      end

      def in_hard_range?(value)
        true
      end

      def out_of_range?(value)
        !in_hard_range?(value)
      end

      def in_soft_range?(value)
        true
      end

      def formatted_value(value)
        value.to_s
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

      def required?
        if option = get_option
          option[:required] == 'required'
        else
          false
        end
      end

      def get_option
        @design.options.select{|o| o[:variable_id] == @variable.id}.first rescue nil
      end

    end
  end
end
