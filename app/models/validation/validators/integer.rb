# frozen_string_literal: true

module Validation
  module Validators
    # Used to help validate values for integer variables.
    class Integer < Validation::Validators::Numeric
      MESSAGES = {
        blank: '',
        invalid: 'Not a Valid Integer',
        out_of_range: 'Integer Outside of Range',
        in_hard_range: 'Integer Outside of Soft Range',
        in_soft_range: ''
      }

      def messages
        MESSAGES
      end

      private

      def get_number(value)
        Integer(format('%d', value))
      rescue
        nil
      end
    end
  end
end
